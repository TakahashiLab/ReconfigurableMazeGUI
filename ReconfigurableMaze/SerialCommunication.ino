////メインループ内関数////
//シリアル通信
void SerialCommunication(){

  //dataがなければ終了
  if( Serial.available() == 0 ) return;

  //先頭１バイト（＝識別コード）を読み取る
  int inputchar = Serial.read();

  //シグナル識別コードによって制御の分岐
  switch(inputchar){
    //識別コード「A」の場合
    case 'A':
      //現在のセンサ/アウトプットの対応をシリアル通信で送る
      SendSnsr2OutputParing();
      break;

    //識別コード「B」の場合
    case 'B':
      //センサ/アウトプットの対応をシリアルで受信して適用する
      
      //バッファが溜まるのを待つ
      //データは９バイトで１セット
      delay(190);
      
      //シリアル通信のデータをもとにセンサ・アウトプット対応を編集
      EditSnsr2Output();   
      break;

    //識別コード「C」：セッションの設定をシリアルで受信して適用する
    case 'C':
      //バッファが溜まるのを待つ
      //データは初期状態８、スタートセンサ４、ゴールセンサ４、セッション数１の１７バイト
      delay(200);

      //セッション情報を編集
      EditSession();
      break;

    //識別コード「D」：セッションの開始
    case 'D':
      //すでにセッションが開始している場合なにもしない
      if(sessions.session_mode) break;
    
      //セッション開始フラグ
      sessions.session_mode = true;
      //セッションの状態＝待機
      sessions.state = 0;
      //セッションの回数＝０
      sessions.session_count=0;
      //正常にセッションが始めったことを返信
      Serial.write('d');
      //ゲートを初期状態にする
      GateInitialize();

      break;

    //識別コード「E」：セッションの終了
    case 'E':
      //セッション開始フラグ
      sessions.session_mode =false;
      //セッションの終了を返信
      Serial.write('e');
      Serial.write(char(sessions.session_count++)); //debug

      break;

    //識別コード「G」の場合：mill2outputの対応をシリアルで受信して適用する
    case 'G':      
      //バッファが溜まるのを待つ
      //データは10バイトで１セット
      delay(100);
      
      //シリアル通信のデータをもとにセンサ・アウトプット対応を編集
      EditMill2Output();
      
      break;
      
    //識別コード「H」の場合：分岐・正解列のデータを受信する
    case 'H':
      //バッファがたまるのを待つ
      //データは最大２７バイト
      delay(50);
      
      EditUserData2();
      break;

    case 'J':
      //バッファが溜まるのを待つ
      delay(100);
      
      AlternationMode();
      //EchoBack();
      break;

    case 'Z':
      //バッファが溜まるのを待つ
      delay(200);

//      //セッション中、デバグボタンからPWM波をオンオフする
//      if( TCCR1A == 0b00100001 ){
//        TCCR1A = 0b00000001;
//      }
//      else if( TCCR1A == 0b00000001 ){
//        TCCR1A = 0b00100001;
//      }

      Serial.write('z');
      //EchoBack();
      break;

    //未定義な識別コード
    default:
      //動作なし
      break;
  }
}


///シリアル通信関連///
//識別コード「A」の場合：現在のセンサ・アウトプット対応をシリアル通信で送る
//-------------------------------------------------------------------------
//([アウトプットピン](０、２２～３７）[出力]（０～１）)×４　snsr2output[0]
//…
//([アウトプットピン](０、２２～３７）[出力]（０～１）)×４　snsr2output[11]
//以上により　８×１２　＝　９６バイトのデータを送信する
//-------------------------------------------------------------------------
void SendSnsr2OutputParing(){

  //識別コード
  //Serial.write('a');

  //インデックス
  int i, j;

  //センサの数
  for(i=0;i<12;i++){

    //アウトプットの数
    for(j=0;j<4;j++){

      //アウトプットの種類
      Serial.write(how2output[i].pinNum[j]);

      //ハイロー
      int HL = 0;
      if(how2output[i].output[j] == true) HL=1;
      Serial.write( char(HL) );
    }
  }
}


///シリアル通信関連///
//識別コード「B」の場合：センサ・アウトプット対応を編集する
void EditSnsr2Output(){

  //データは[センサ番号]([出力先番号][出力内容][連続動作不許可][遅延時間])×４の１７バイト

  //データ長が不正な場合はバッファを空にして終了
  if(Serial.available() != 17){
    while(Serial.available()) Serial.read();
    return;
  }

  //編集するピンのインデックス。GUIから０～１１のいずれかを受け取る ※ノーズポーク対応中…ピンってなんだっけ
  int i = int( Serial.read() );

  //編集するインデックスに対応するセンサ。インデックス（０～）センサ（３８～）
  how2output[i].snsrNum = i + 38;

  int j=0;
  int c;
  
  //設定可能なセンサアウトプット対応（最大４）
  for(;j<4;j++){

    //アウトプットピン。GUIから０、２２～３７のいずれかを受け取る
    how2output[i].pinNum[j] = Serial.read();

    //ピンの操作内容。GUIから０か１のいずれかを受け取る
    c = int( Serial.read() );
    if(c==1){
      how2output[i].output[j] = true;
    }else{
      how2output[i].output[j] = false;
    }

    //連続動作の不許可フラグ
    how2output[i].mlt_disallow[j] = Serial.read();

    //遅延時間
    how2output[i].delay_time[j] = Serial.read();
  }
}


///シリアル通信関連///
//識別コード「C」の場合：セッションを編集する
//通信部では、データの数値は受け取るだけ。解釈は実行部に書く
void EditSession(){

  //データは[初期状態]×８[スタートセンサ]×４[ゴールセンサ]×４[セッション数]
  //の１７バイト▲▲

  //データ長が不正な場合はバッファを空にして終了
  if(Serial.available() != 17){
    while(Serial.available()) Serial.read();
    return;
  }

  int i;

  //初期状態　受信データは０か１。ゲート１～８。出力ピンとしては２２～２９
  for(i=0;i<8;i++){
    sessions.initialstate[i] = Serial.read();
  }

  //スタートセンサ　受信データは０未使用、１～８センサ、９～１０ミルセンサ
  for(i=0;i<4;i++){
    sessions.startSnsr[i] = Serial.read();
  }

  //ゴールセンサ　受信データは０、１～８センサ、９～１０ミルセンサ
  for(i=0;i<4;i++){
    sessions.goalSnsr[i] = Serial.read();
  }

  //セッション数 データは０～１２７。
  sessions.session_num = Serial.read();
}


///シリアル通信関連///
//識別コード「G」の場合：トレッドミルの動作時間および、停止後のアウトプットを編集
void EditMill2Output(){

  //データは[センサ番号]([出力先番号][出力内容])×４[動作時間]の１０バイト

  //データ長が不正な場合はバッファを空にして終了
  if(Serial.available() != 10){
    while(Serial.available()) Serial.read();
    return;
  }

  //編集するピンのインデックス。GUIから０～１のいずれかを受け取る
  int i = int( Serial.read() );
  
  int j;
  int c;
  
  //設定可能なセンサアウトプット対応（最大４）
  for(j=0;j<4;j++){

    //アウトプットピン。GUIから０、２２～３７のいずれかを受け取る
    mill2output[i].pinNum[j] = Serial.read();

    //ピンの操作内容。GUIから０か１のいずれかを受け取る
    c = int( Serial.read() );
    if(c==1){
      mill2output[i].output[j] = true;
    }else{
      mill2output[i].output[j] = false;
    }
  }
  
  //ミルの動作時間　1バイトの数値型で送られてくるので、そのままintに直せばおｋ
  mill2output[i].milltime = int( Serial.read() );
}


///シリアル通信関連///
//識別コード「H」の場合：
//ループ毎に、次のユーザ定義出力と、正解のセンサの列をシリアルで受信し
//session構造体に格納する
void EditUserData2(){
  
  //[セッションのインデックス]
  //[正解センサ１][正解センサ２]…[区切りコード127]　最大１６＋１バイト
  //[ユーザ出力１][ユーザ出力２]…[区切りコード127]　最大８　＋１バイト
  //受け取るデータはセンサまたは出力のピンアサインを表す１バイトの数値
  
  int id = int( Serial.read() );

  for(int i=0;i<8;i++){
    char s = Serial.read();
    if( int(s) == 127 ) break;
    userdata[id].correctroot[i] = s;
  }

  for(int i=0;i<8;i++){
    char s = Serial.read();
    if( int(s) == 127 ) break;
    userdata[id].useroutput[i] = s;
  }
  
  //あまっているバッファがあれば空に
  while(Serial.available()){
    char s = Serial.read();
  }
  
  //オルタネイションモードと競合しないように
  sessions.alternation = false;
  
}


///シリアル通信関連///
//識別コード「J」の場合：オルタネイションモードの設定をする
void AlternationMode(){
  
  //オルタネイションモードに
  sessions.alternation = true;
  
  //正解となる２つのセンサ列を受信する
  for(int i=0;i<8;i++){
    char s = Serial.read();
    if( int(s) == 127 ) break;
    sessions.alterroot1[i] = s;
  }
  //正解となる２つのセンサ列を受信する
  for(int i=0;i<8;i++){
    char s = Serial.read();
    if( int(s) == 127 ) break;
    sessions.alterroot2[i] = s;
  }
  
  //正解ルートuserdata[0].correctroot[0-7]を初期化
  for(int i=0;i<8;i++){
    userdata[0].correctroot[i] = 0;
  }
}


//デバグ用エコーバック★
void EchoBack(){

  //バッファがある限り
  while(Serial.available()){

    //読んだデータをそのまま帰す
    char a = char( Serial.read() );
    Serial.write(a);
  }
}

