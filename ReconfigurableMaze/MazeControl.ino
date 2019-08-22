/*
 * 迷路の動作制御関連。おおむね次の関数を記述
 * 
 * 
 */
 //構造体：出力をタイマーでデクリメントしながら管理する
typedef struct {
  char    pinNum[16];
  bool    output[16];
  double  dly[16];
} outputcontrol_t;
volatile  outputcontrol_t outputcontrol;


//構造体の初期化関数
void Initialize_outputcontrol(){
  
  for(int i=0; i<16; i++){
    outputcontrol.pinNum[i] =0;
    outputcontrol.output[i]   =false;
    outputcontrol.dly[i]    =0;
  }
}


//タイマ割り込みによる、遅延出力の制御
void OutputControl(){

  //スタックは最大１６まで
  for(int l=0; l<16; l++){

    //アウトプットが定義されていれば
    if(outputcontrol.pinNum[l] > 0){  //○

      //残り時間をデクリメント
      outputcontrol.dly[l] -= 100;

      //if(outputcontrol.dly[l]>0) {delay(1000);}

      //残り時間がなくなれば
      if(outputcontrol.dly[l] <1){  //○

        //出力を行う
        if(outputcontrol.output[l]){
          digitalWrite(outputcontrol.pinNum[l], HIGH);  //○
        }
        else{
          digitalWrite(outputcontrol.pinNum[l], LOW);
        }

        //アウトプットのスタックを空に
        outputcontrol.pinNum[l] = 0;
        outputcontrol.output[l] = 0;
        outputcontrol.dly[l] = 0;
      }
    }
  }

  //タイマ終了判定
  int i=0;
  for(int j=0; j<16; j++){
    i+= outputcontrol.pinNum[j];
  }
  if(i==0) FlexiTimer2::stop();

  //○

//  //タイマ動作確認,pin13は他の処理と競合するので避ける
//  pinMode(13, OUTPUT);
//  if(millflag2){
//    digitalWrite(13, HIGH);
//    millflag2 = !millflag2;
//  }else{
//    digitalWrite(13, LOW);
//    millflag2 = !millflag2;
//  }
}


////メインループ内////
//センサピンの番号を受け取り、そのセンサに対応するユーザ定義の出力を行う
void Snsr2Output(int i){
  
  //iは０～１１。snsr2outputo[i]のインデックス。センサ３８～４５、ミルセンサ４６、４７に対応

  //出力先ピンを指定するインデックス
  int j;

  //出力
  for(j=0;j<8;j++){

    //出力先が定義されていれば。pinNumは０、２２～３７、１０１～１０２
    if(how2output[i].pinNum[j] > 0){

      //charをintに変換。分岐処理用の記述。とりあえず残す
      int k = how2output[i].pinNum[j];  //○

      //連続動作を不許可にする場合、センサ履歴を参照し、最新の履歴と今回反応したセンサが一致する場合、出力を行わない
      //連続動作フラグ
      bool flg = false;

      //連続動作不許可の場合
      if(how2output[i].mlt_disallow[j]){
        
        //履歴が空の場所までインデックスを動かす
        int m=0;
        for(;m<16;m++){
          if( sessions.thistimeroot[m] == 0 ) break;
        }

        if(m<1) m=1;
        if( sessions.thistimeroot[m-1] == (i+38) ) flg = true;
      }

//      //出力先が分岐の場合
//      //分岐先のピンアサインをｋに格納しなおす
//      if(100<k && k<109){
//        k = sessions.useroutput[k-101];
//      }

      //連続動作を不許可しない場合
      if(flg==false){

        //ディレイが設定されていなければ
        if(how2output[i].delay_time[j] == 0){
  
          //即時処理
          if(how2output[i].output[j]){
            digitalWrite(how2output[i].pinNum[j], HIGH);
          }
          else{
            digitalWrite(how2output[i].pinNum[j], LOW);
          }
  
        //ディレイがある場合
        }else{
  
          //スタックに同じ出力先があり、さらに出力内容も同じ場合、フラグを立てて出力の処理を飛ばす
          bool flag = false;
          for(int l=0; l<16; l++){
  
            //同じ出力先であり
            if(outputcontrol.pinNum[l]==how2output[i].pinNum[j]){
  
              //同じ出力内容である場合
              if(outputcontrol.output[l]==how2output[i].output[j]){
  
                flag = true;
                break;
              }
            }
          }
  
          //スタックに同じ出力がない場合
          if(flag==false){
            
            //処理用スタックに出力の情報を渡す
            for(int l=0; l<16; l++){
              
              //空のインデックスがあったら
              if(outputcontrol.pinNum[l]==0){
                outputcontrol.pinNum[l]    = char(k); //○
                outputcontrol.output[l]      = how2output[i].output[j];
                outputcontrol.dly[l]       = how2output[i].delay_time[j] * 1000; //msec
                break;
              }
            }
            
            //タイマ割り込みによる遅延出力
            FlexiTimer2::set(100, OutputControl);
            FlexiTimer2::start();
          }
        }
      }
    }
  }
}

