//Mega用タイマー割り込み
#include <FlexiTimer2.h>
//PWM出力用レジスタ設定
#include <avr/io.h>


//セッション数・センサ列の上限
#define MAXSESSION    255
#define MAXROOT       8
#define MAXCHOICE     2


//porking1を検知してfeed1するためのインタラプトピン
#define PORKtoFEED1   2
#define PORKtoFEED2   3


//出力用pin ２２～３７の１６チャンネル
#define GATE1         22
#define GATE2         23
#define GATE3         24
#define GATE4         25
#define GATE5         26
#define GATE6         27
#define GATE7         28
#define GATE8         29
#define LOWMILL1      30  //ミル１のスピード１稼働
#define LOWMILL2      31
#define DIRofMILL1    32  //ミル１の向き
#define DIRofMILL2    33
#define FEED1         34
#define FEED2         35
#define DISCARD1      36
#define DISCARD2      37
//入力用pin 51,52をTFTで使う場合３８～４９の１２チャンネル
#define SENSOR1       38  //誤作動
#define SENSOR2       39
#define SENSOR3       40
#define SENSOR4       41
#define SENSOR5       42
#define SENSOR6       43
#define SENSOR7       44
#define SENSOR8       45
#define MILLSENSOR1   46
#define MILLSENSOR2   47
#define PORKING1      48
#define PORKING2      49  //割当は存在する


//構造体：センサ入力があったときの出力の定義
typedef struct {
  int   snsrNum;    //この構造体が定義するセンサ出力の番号
  char  pinNum[8];  //０で未使用。２２～３７
  bool  output[8];  //trueがHIGH,falseがLOW
  char  mlt_disallow[8];  //連続動作の不許可 1が不許可
  char  delay_time[8];    //遅延時間 0で遅延なし
  int   milltime;   //トレッドミルの動作時間
} how2output_t;
//最大１２。センサ８。ミルセンサ２。ポーキング２。
//[0-7]がセンサ１～８,[8-9]ミルセンサ１～２,[10-11]がポーキングに対応
volatile  how2output_t how2output[12]; //ここ増やす
volatile  how2output_t mill2output[2];


//構造体：セッションを管理する
typedef struct {
  //セッションモードになったかどうか。true：セッション中
  bool  session_mode;
  //最初にゲートをどのような状態にしておくか。０：閉、１：開
  char  initialstate[8];
  //セッションのスタートとゴールのセンサ
  //未使用０、センサ１～８、ミルセンサ９～１０
  char  startSnsr[4];
  char  goalSnsr[4];
  int   session_num;    //セッションの数
  char  state;          //０：待機、１：セッション中
  int   session_count;  //現在のセッション
  char  thistimeroot[16];  //通ったセンサの履歴
  char  correctroot[16];//今回のセッションでの正解となるセンサの列
  char  useroutput[8];  //分岐用のアウトプット
  bool  alternation;    //オルタネイションモードの検出
  char  alterroot1[8];
  char  alterroot2[8];
  bool  is_success;     //エサを得たかどうか
  int   success_trials; //成功トライアルの数
  //未使用
  int   sessiontime;    //セッションスタートからの時間経過
  char  correctfeeder;  //エサを提示する正解のFeed
  char  whichisporked;  //ポーク検知。０かセンサのピンアサイン
} sessions_t;
volatile sessions_t sessions;


//構造体：タスクのログを管理する
typedef struct {
  char snsr[1000];
  unsigned long clck[1000];
} tasklog_t;
//volatile tasklog_t tasklog; //ログのArduino保存は現実的でないかもしれぬ


//構造体：分岐・センサの列格納
typedef struct {
  char correctroot[MAXROOT];
  char useroutput[MAXCHOICE];
} userdata_t;
volatile userdata_t userdata[MAXSESSION];


//擬似乱数シード
volatile int randnum = 100;
volatile int randseed[100] = {
0, 0, 0, 0, 0, 0, 1, 0, 0, 0,
0, 1, 0, 0, 0, 0, 0, 0, 0, 0,
1, 0, 0, 0, 0, 0, 0, 1, 0, 0,
0, 1, 0, 0, 1, 0, 0, 0, 0, 0,
0, 0, 1, 0, 0, 0, 1, 0, 0, 0,
0, 0, 0, 0, 1, 0, 0, 0, 0, 0,
0, 0, 1, 1, 0, 0, 0, 0, 0, 1,
1, 1, 0, 0, 0, 0, 1, 0, 0, 1,
0, 0, 1, 0, 0, 0, 1, 0, 1, 0,
0, 0, 0, 0, 0, 1, 0, 0, 0, 0 }; //２０％の確率で出ない
          
//volatile int randseed[30] = {1 , 0 , 1 , 0 , 1 , 0 , 1 , 0 , 1 , 0 , 1 , 1 , 0 , 1 , 1 , 0 , 1 , 0 , 1 , 0 , 0 , 1 , 0 , 0 , 1 , 0 , 1 , 0 , 1 , 0}; //15
//volatile int randseed[30] = {1 , 1 , 0 , 0 , 1 , 0 , 0 , 1 , 1 , 0 , 1 , 0 , 0 , 1 , 0 , 1 , 0 , 0 , 1 , 0 , 1 , 0,  1 , 0 , 0 , 1 , 0 , 1 , 0 , 0}; //13


//ミルを連続稼動させないためのフラグ
volatile bool millflag1 = false;
volatile bool millflag2 = false;

//青い制御箱をオンオフする場合のバグ対策
volatile bool blueboxisoff = false;


////タイマー割り込み////
void DelayedFeed1_OFF(){
  digitalWrite(FEED1, LOW);
  //FlexiTimer2::stop();
}
void DelayedFeed2_OFF(){
  digitalWrite(FEED2, LOW);
  FlexiTimer2::stop();
}
void DelayedFeed1_ON(){
  digitalWrite(FEED1, HIGH);
  //digitalWrite(FEED2, HIGH); //////
  FlexiTimer2::stop();
}
void DelayedFeed2_ON(){
  digitalWrite(FEED2, HIGH);
  FlexiTimer2::stop();
}

////セットアップ////
void setup() {

  //PWM波の出力用設定
  pinMode(12, OUTPUT);
  //ユーザ設定部
  unsigned int frq = 100; // 周波数
  float duty = 0.5; // 指定したいデューティ比
  // モード指定
  TCCR1A = 0b00000001;
  TCCR1B = 0b00010010;  //分周８
  // TOP値指定
  OCR1A = (unsigned int)(1000000 / frq);
  // Duty比指定
  OCR1B = (unsigned int)(1000000 / frq * duty);

  //13pinから延長コード付きスイッチ制御
  pinMode(13, INPUT_PULLUP);
  
  //外部制御装置の電源オンオフを検知
  pinMode(10, INPUT);

  //ピンモードの初期化
  for(int i=22;i<38;i++){
    pinMode(i, OUTPUT);
  }
  for(int i=38;i<50;i++){
    pinMode(i, INPUT);
  }
  
  //エサ出し用のインタラプトピン
  pinMode(PORKtoFEED1, INPUT);
  pinMode(PORKtoFEED2, INPUT);
  attachInterrupt(digitalPinToInterrupt(PORKtoFEED1), Feed1, RISING);
  attachInterrupt(digitalPinToInterrupt(PORKtoFEED2), Feed2, RISING);

  // シリアルポートを9600bpsで初期化
  Serial.begin(9600);

  //how2output構造体の初期化
  int i;
  int num=38;
  for(i=0;i<12;i++){

    //how2output[12]に先頭から３８～４９の１２本のセンサピンの動作を格納
    how2output[i].snsrNum = num;
    num++;

    int x;
    for(x=0;x<8;x++){
      how2output[i].pinNum[x] = 0x00;   //ターゲット出力ピン。0x00（未使用）で初期化
      how2output[i].output[x] = false;  //ターゲット出力ピンの処理。すべてLOWで初期化
    }
  }
  
  //mill2output構造体の初期化
  for(i=0;i<2;i++){
    int x;
    for(x=0;x<8;x++){
      mill2output[i].pinNum[x] = 0x00;   //ターゲット出力ピン。0x00（未使用）で初期化
      mill2output[i].output[x] = false;  //ターゲット出力ピンの処理。すべてLOWで初期化
    }
    mill2output[i].milltime = 0;
  }
  
  //userdata構造体の初期化
  for(i=0;i<MAXSESSION;i++){
    int j;
    for(j=0;j<MAXROOT;j++){
      userdata[i].correctroot[j] = 0;
    }
    for(j=0;j<MAXCHOICE;j++){
      userdata[i].useroutput[j] = 0;
    }
  }

  //outputcontrol構造体を初期化
  Initialize_outputcontrol();

  //セッション構造体を初期化
  sessions.session_mode = false;
  sessions.session_count = 0;
  ResetThisTimeRoot();
  sessions.alternation = false;
  sessions.is_success = false;
  sessions.success_trials = 0;
 
  
  //Arudinoの再起動時、すべての出力をLOWに
  for(i=22;i<38;i++){
    digitalWrite(i, LOW);
  }

//  //***マガトレ用セッションモード
  //sessions.session_mode = true;
}


////メインループ////
void loop() {

//  //外部スイッチ給餌feeder1:task中にスイッチで連続給餌　※スイッチで何度も給餌（タスク中）
//  if(digitalRead(13) == LOW){
//    digitalWrite(FEED1, LOW);
//    //digitalWrite(FEED2, LOW); ///////
//    FlexiTimer2::set(10, DelayedFeed1_ON);
//    FlexiTimer2::start();
//  }
  
//外部スイッチPWNオンオフ
if(digitalRead(13) == LOW){
  if( TCCR1A == 0b00100001 ){
    TCCR1A = 0b00000001;
  }
  else if( TCCR1A == 0b00000001 ){
    TCCR1A = 0b00100001;
  }
  delay(1000);
}
  
//  //Arduino起動中に、シールドボックスがオンオフされる場合のバグ対策
//  //青箱の電源がオンになった場合
//  if(digitalRead(10)==HIGH && blueboxisoff){
//    delay(1000);
//    blueboxisoff = false;
//  }  
//  //青箱の電源がオフである場合
//  if(digitalRead(10)==LOW){
//    //青箱をオフにするタイミングで、インタラプトが呼ばれ、FEEDがHIGHになる
//    digitalWrite(FEED1,LOW);
//    digitalWrite(FEED2,LOW);
//    blueboxisoff = true;
//    return;
//  }
  
  //シリアル通信
  SerialCommunication();

  //センサ入力の感知
  //sensor==HIGHのときの処理
  //センサピンはセンサ３８～４５、ミルセンサ４６～４７、ポーキング４８～４９*未使用*
  int i;
  if(sessions.session_mode){
    for(i=0;i<10;i++){
      if(digitalRead(i+38)==HIGH){
        
        //対応する出力を出す
        //Snsr2Output2(i);
        Snsr2Output(i);
        //センサの履歴を記録する
        if(sessions.state == 1) SnsrRecord(i+38);
        //スタートとゴールの処理
        SessionControl2(i+38);

//        //現在のセンサ列を送る。＊＊一時的表現, 通信バグの元。matlabの受信改善まで非仕様を推奨
//        if(sessions.state == 1){
//          Serial.write('i');
//          int j;
//          for(j=0;j<8;j++){
//            Serial.write(userdata[sessions.session_count].correctroot[j]);
//          }
//          for(j=0;j<8;j++){
//            Serial.write(sessions.thistimeroot[j]);
//          }
//        }
      }
    }
  }
}


////メインループ内////
//センサピンの番号を受け取り、そのセンサに対応するユーザ定義の出力を行う
void Snsr2Output2(int i){
  
  //iは０～１１。snsr2outputo[i]のインデックス。センサ３８～４５、ミルセンサ４６、４７に対応

  //出力先ピンを指定するインデックス
  int j;
  
  //すでにそのミルが動いていて、かつ
  //センサ出力がミルの動作を含む場合、関数を抜ける
  if(millflag1){
    for(j=0;j<8;j++){
      if(how2output[i].pinNum[j] == 30) return;
    }
  }
  if(millflag2){
    for(j=0;j<8;j++){
      if(how2output[i].pinNum[j] == 31) return;
    }
  }

 //この関数内でミルの動作を実現するフラグ
  bool flag1=false;
  bool flag2=false;

  //出力
  for(j=0;j<8;j++){

    //出力先が定義されていれば。pinNumは０、２２～３７、１０１～１０２
    if(how2output[i].pinNum[j] != 0){

      //charをintに変換
      int k = how2output[i].pinNum[j];
      
      //出力先が分岐の場合
      //分岐先のピンアサインをｋに格納しなおす
      if(100<k && k<109){
        k = sessions.useroutput[k-101];
      }
      
      //対応する出力ピンに目的の出力を出す
      if(how2output[i].output[j]==true) digitalWrite(k, HIGH);
      if(how2output[i].output[j]==false) digitalWrite(k, LOW);
      
      //ミルの動作が出力された場合、フラグを立てる
      if(k==30) flag1 = true;
      if(k==31) flag2 = true;
    }
  }
  
  //ミル1の動作
  if(flag1){
    //指定時間ミル１を動かす
    delay(mill2output[0].milltime * 1000);
    //ミル１を停止
    digitalWrite(30, LOW);
    
    for(j=0;j<8;j++){
  
      //出力先が定義されていれば。pinNumは０、２２～３７
      if(mill2output[0].pinNum[j] != 0){
  
        //charをintに変換
        int k = mill2output[0].pinNum[j];
  
        //対応する出力ピンに目的の出力を出す
        if(mill2output[0].output[j]==true) digitalWrite(k, HIGH);
        if(mill2output[0].output[j]==false) digitalWrite(k, LOW);
      }
    }
    
    //ミル1を複数回稼動させないためのフラグ
    millflag1 = true;
  }
  //ミル２の動作
}


////メインループ内////
//セッションの管理（スタートとゴールの処理）
void SessionControl2(int pin){
  
  //pin はHIGHを読み取ったセンサの番号。３８～４９
  
  int i;
  
  //Startの検出　からの　スタートの処理
  if( sessions.state == 0 ){
    
    //スタートセンサは最大４本
    for(i=0; i<4; i++){
      
      //startSnsrは値　未使用０、センサ１～８、ミルセンサ９～１０
      //ピンアサインは　センサ３８～４５、ミルセンサは４６～４７
           
      //スタートセンサが定義されているなら
      if(sessions.startSnsr[i] > 0){
        
        //読み取ったセンサ入力とスタートセンサを比較
        if(pin == (sessions.startSnsr[i]+37) ){
          
          //エサの破棄を再度可能に
          digitalWrite(DISCARD1, LOW);
          digitalWrite(DISCARD2, LOW);
          
          //セッションの状態を変更
          sessions.state = 1;
          
          //センサ列にスタートのセンサを加える
          SnsrRecord(pin);
          
          return;
        }
      }
    }
  }

  //Goalの検出
  if( sessions.state == 1 ){
    
    //ゴールセンサは最大４本
    for(i=0; i<4; i++){
      
      //goalSnsrは値　未使用０、センサ１～８、ミルセンサ９～１０
      //ピンアサインは　センサ３８～４５、ミルセンサは４６～４７
           
      //ゴールセンサが定義されているなら
      if(sessions.goalSnsr[i] > 0){
        
        //読み取ったセンサ入力とゴールセンサを比較
        if(pin == (sessions.goalSnsr[i]+37) ){

          //goalの処理
          
          //オルタネイションモードの場合、次のセッションの正解ルートを更新
          if(sessions.alternation) SetNextCorrectRoot();
          //トライアル回数をインクリメント
          sessions.session_count++;
          //トライアルの成功数をカウント
          if(sessions.is_success) sessions.success_trials++;

          //matlab側にセッションのデータを通信
          SendSessionData();

          //***エサの破棄
          //digitalWrite(DISCARD1, HIGH);
          //digitalWrite(DISCARD2, HIGH);

          //エサを再供給可能に
          digitalWrite(FEED1, LOW);
          digitalWrite(FEED2, LOW);
          
          //ミル稼動フラグを下げる
          millflag1 = false;
          millflag2 = false;
          
          //今回のセンサ列をリセットする
          ResetThisTimeRoot();

          //トライアルの成否関係
          sessions.is_success = false;

          //セッションの状態を変更
          sessions.state = 0;
          
          return;
        }
      }
    }
  }
}


////メインループ内////
//センサを感知するたびに呼ばれる。通ったセンサの履歴を更新
void SnsrRecord(int num){
  
  //numは感知したセンサのピンアサイン値
  
  //センサの履歴を格納するインデックス
  int i=0;
  
  //履歴が空の場所までインデックスを動かす
  for(;i<16;i++){
    if( sessions.thistimeroot[i] == 0 ) break;
  }
  
  //同じセンサが連続して履歴には入らない
  if(i>0){
    if( sessions.thistimeroot[i-1] == num ) return;
  }
  
  //履歴の更新
  sessions.thistimeroot[i] = char(num);
}


///セッション関連///
//セッション終了時に、セッションの情報を送る。次セッション情報のコールを兼ねる
//['f'][セッション回数][センサの履歴][正解不正解][正解数] … 1+8+1+1 bytes
void SendSessionData(){

  //識別コード「f」
  Serial.write('f');
  //セッション回数
  Serial.write( char(sessions.session_count) );
  //センサの履歴
  for(int j=0;j<8;j++){
    Serial.write(sessions.thistimeroot[j]);
  }
  Serial.write(sessions.is_success);
  Serial.write( char(sessions.success_trials));
 
  
  //経過時間
  //長さ不定なのでprintと改行コードで一気に送る
  //Serial.print( sessions.sessiontime );
  //Serial.write('\n');
}


///セッション関連///
//GUIからセッション開始信号をもらったら一度だけ実行
//迷路のゲートを初期状態にする
void GateInitialize(){

  //initialstate[i]は開いておきたいゲートなら１が入る
  //インデックスは０～７。ゲートは２２～２９

  int i;
  //HIGHで開ける。LOWで閉まる
  for(i=0; i<8 ;i++){
    if(sessions.initialstate[i]) {
      //開けておきたいゲートなら
      digitalWrite(i+22, HIGH);
    }else{
      //そうでなければ
      digitalWrite(i+22, LOW);
    }
  }
}


///セッション関連///
//thistimerootを初期化する
void ResetThisTimeRoot(){
  for(int i=0;i<16;i++){
    sessions.thistimeroot[i] = 0;
  }
}


///セッション関連///
//オルタネーションモードで、次の正解センサ列を設定する★
void SetNextCorrectRoot(){
  
//  for(int j=0;j<8;j++){
//    userdata[sessions.session_count + 1].correctroot[j] = sessions.alterroot2[j];
//  }
  
  //今回のルートと正解ルート１を比較する
  for(int i=0;i<8;i++){
    
    char c = sessions.alterroot1[i];
    
    //今回のルートが正解ルート１と一致しつづけてループを抜けなかった→次はルート２
    if(c == 0){
      for(int j=0;j<8;j++){
        userdata[sessions.session_count + 1].correctroot[j] = sessions.alterroot2[j];
      }
      return;
    }
    
    //今回のルートは正解ルート１と不一致（ルート２を通った）→次はルート１
    if(c != sessions.thistimeroot[i]){
      for(int j=0;j<8;j++){
        userdata[sessions.session_count + 1].correctroot[j] = sessions.alterroot1[j];
      
      }
     return; 
    }
  }
}
 

///インタラプト///
//ポーキングを検出してエサを出す
void Feed1(){
  
  //if(blueboxisoff) return;
  if(!sessions.session_mode) return;
  
  //正解センサ列と一致する場合のみ給餌
  for(int i=0;i<MAXROOT;i++){
    
    if(userdata[sessions.session_count].correctroot[i] == 0) break;
    if(userdata[sessions.session_count].correctroot[i] != sessions.thistimeroot[i]) return;
  }
  
  

//  //ランダムで餌を出さないヤツ
//  int cnt = sessions.session_count % randnum ;
//  if(randseed[cnt]){
//    return;
//  }
  
  //feederは一度lowに落とさないと再起動しないので、この記述で１回しか動かない
  digitalWrite(FEED1, HIGH);
  sessions.is_success = true;
}


void Feed2(){
  
  //if(blueboxisoff) return;
  if(!sessions.session_mode) return;

  //正解センサ列と一致する場合のみ給餌
  for(int i=0;i<MAXROOT;i++){
    
    if(userdata[sessions.session_count].correctroot[i] == 0) break;
    if(userdata[sessions.session_count].correctroot[i] != sessions.thistimeroot[i]) return;
  }
  
  //feederは一度lowに落とさないと再起動しないので、この記述で１回しか動かない
  sessions.is_success = true;
  digitalWrite(FEED2, HIGH);
}
