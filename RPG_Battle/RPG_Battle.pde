import ddf.minim.*;

Minim minim;

// グローバル変数
int situation = 1; // シチュエーションを表す番号(バトル)
boolean enterCheck = false; // エンターを押したか動画を判定(バトル)
int mapOrBattleOrCreditsRollOrTitle = 3; // 0の時マップ画面、1の時バトル画面、2の時エンドロール画面、3の時タイトル画面
int creditsCount = 1; // クレジットの番号を保持する変数(エンドロール)
int startOrExit = 0; // 0の時START,1の時EXIT
// ここまで（グローバル変数）

//キャラクターのクラス
class Chara {
    int HP, HP_max, AT1, AT2, DP; //体力、攻撃力、防御力
    String NAME; //名前
    PImage img; //キャラ画像
    Chara(String name, String figure, int hp, int at1, int at2, int dp) {
        NAME = name;
        img = loadImage(figure);
        HP = hp;
        HP_max = hp;
        AT1 = at1;
        AT2 = at2;
        DP = dp;
    }

    void display(int x, int y, int w, int h) { //表示する
        image(img, x, y, w, h);
    }
}

//キャラクターの横の体力ゲージなどの部分
class Status {
    int x, y, HP;
    Status(int x0, int y0, int hp) {
        x = x0;
        y = y0;
        HP = hp;
    }

    void display(String name, int hp) { //表示と位置
        fill(255);
        strokeWeight(2);
        rect(x-10, y-50, 550, 160);
        textName(name, x, y);
        HPbar(hp, x, y+20);
        textHP(hp, x, y+100);
    }

    void textName(String name, int textX, int textY) { //名前表示
        fill(0);
        textSize(50);
        text(name, textX, textY);
    }

    void HPbar(int hp, int barX, int barY) { //体力ゲージ
        fill(200, 200, 200);
        strokeWeight(2);
        rect(barX, barY, 500, 20);
        if((float(hp)/HP) * 497 <= 497/2.0){ //体力げゲージの色分け
            if((float(hp)/HP) * 497 <= 497/6.0){
                fill(255, 0, 0);
            }else{
                fill(255, 255, 0);
            }
        }else{
            fill(0, 255, 0);
        }
        strokeWeight(0);
        rect(barX+2, barY+2, (float(hp)/HP) * 497, 17);
    }

    void textHP(int hp, int textX, int textY) { //体力表示
        fill(0);
        textSize(50);
        text(hp + "/" + HP, textX, textY);
    }
}

// バトル画面で表示するテキスト
class Text {
    int select = 0;
    void display(int rextX, int rectY, int w, int h, int textX, int textY, int size, String message) {  
        fill(255);
        strokeWeight(2);
        rect(rextX, rectY, w, h);
        rect(rextX+5, rectY+5, w-10, h-10);
        fill(0);
        textSize(size);
        text(message, textX, textY);
    }
    void command() {
        // テキスト上で選択したいときに使う（攻撃方法を選ぶ時とか）
    }
}

// バトル中選択が問われるときに出るテキスト(Textクラスを継承)
class selectText extends Text {
    void command() {
        if(key == '1') {
            select = 1;
        } else if(key == '2') {
            select = 2;
        }
    }
}

// マップ用クラス
class map {
  // マップの座標を記録した配列(16×12)・0が道、1がオブジェ(草とか木とか)
  int[][] pixelNumber = { {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
                          {1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1},
                          {1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1},
                          {1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1},
                          {1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1}, 
                          {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
                          {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
                          {1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1},
                          {1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1},
                          {1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1},
                          {1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1},
                          {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1} 
                        };
  int pixelCountX = 16;
  int pixelCountY = 12;
  PImage tile = loadImage("images/maptile_sogen_02.png");
  PImage tree = loadImage("images/ki_01.png");
  
  void display() {
    for(int i = 0; i < pixelCountX; i++) {
      for(int j = 0; j < pixelCountY; j++) {
        image(tile, width * i / pixelCountX, height * j / pixelCountY, width / pixelCountX, height / pixelCountY);
        if(pixelNumber[j][i] == 1) {
          //fill(0, 255, 0); // 緑
          image(tree, width * i / pixelCountX, height * j / pixelCountY, width / pixelCountX, height / pixelCountY);
        } else if(pixelNumber[j][i] == 0) {
          //fill(255, 243, 183); // クリーム色
          //image(tile, width * i / pixelCountX, height * j / pixelCountY, width / pixelCountX, height / pixelCountY);
        }
        //rect(width * i / pixelCountX, height * j / pixelCountY, width / pixelCountX, height / pixelCountY);
      }
    }
  }
}

// マップ上のキャラクターに関するクラス
class mapCharacter {
  int i;
  int j;
  int w = 45;
  int h = 45;
  int[][] pixelNumber;
  mapCharacter(int i0, int j0, int[][] pixelNumber0) {
    i = i0;
    j = j0;
    pixelNumber = pixelNumber0;
  }
  void display() {
  }
  void move() {
  }
}

// マップ上のプレイヤ-に関するクラス(mapCharacterクラスを継承)
class mapPlayer extends mapCharacter{
  mapPlayer(int i0, int j0,  int[][] pixelNumber0) {
    super(i0, j0, pixelNumber0);
  }
  void display() {
    fill(0, 0, 255);
    rect(width * i/ 16 + 15, height * j / 12 + 15, w, h);
  }
  void move() {
    if(key == CODED && keyPressed == true) {
      if(keyCode == RIGHT && pixelNumber[j][i + 1] == 0) {
        i += 1;
      } else if(keyCode == LEFT && pixelNumber[j][i-1] == 0) {
        i -= 1;
      } else if(keyCode == UP && pixelNumber[j-1][i] == 0) {
        j -= 1;
      } else if(keyCode == DOWN && pixelNumber[j+1][i] == 0) {
        j += 1;
      }
    }  
  }
}

// マップ上の敵に関するクラス(mapCharacterクラスを継承)
class mapEnemy extends mapCharacter{
  mapEnemy(int i0, int j0, int[][] pixelNumber0) {
    super(i0, j0, pixelNumber0);
  }
  void display() {
    fill(0);
    rect(width * i / 16 + 15, height * j / 12 + 15, w, h);
  }
}

//ゲーム内の音楽関係
class Music {
    AudioPlayer field, bgm, deth, win, attack, heal, explo, push;
    
    void load(){ //音ファイルの読み込み
        field = minim.loadFile("music/maou_game_field09.mp3");
        bgm = minim.loadFile("music/maou_bgm_8bit18.mp3");
        deth = minim.loadFile("music/maou_bgm_8bit20.mp3");
        win = minim.loadFile("music/maou_game_jingle05.mp3");
        attack = minim.loadFile("music/maou_se_battle09.mp3");
        heal = minim.loadFile("music/maou_se_magical21.mp3");
        explo = minim.loadFile("music/maou_se_battle_explosion06.mp3");
        push = minim.loadFile("music/maou_se_system48.mp3");
    }

    void playback(String title){ //再生
        if(title == "field"){
            if(!field.isPlaying()){
                field.loop();
            }
        }else if(title == "bgm"){
            if(!bgm.isPlaying()){
                bgm.loop();
            }
        }else if(title == "deth"){
            if(!deth.isPlaying()){
                deth.loop();
            }
        }else if(title == "win"){
            if(!win.isPlaying()){
                win.loop();
            }
        }else if(title == "attack"){
            attack.play();
            attack.rewind();
        }else if(title == "heal"){
            heal.play();
            heal.rewind();
        }else if(title == "explo"){
            explo.play();
            explo.rewind();
        }else{
            push.play();
            push.rewind();
        }
    }

    void musicStop(String title){ //一時停止
        if(title == "field"){
            field.pause();
            field.rewind();
        }else if(title == "bgm"){
            bgm.pause();
            bgm.rewind();
        }else{
            deth.pause();
            deth.rewind();
        }
    }

    void end(){ //停止
        bgm.close();
        deth.close();
        attack.close();
        heal.close();
        push.close();
    }
}

//エンドロール用のクラス
class creditsRoll {
  float x = width / 2;
  float y;
  int count;
  int slideSpeed = 1;
  String message1;
  String message2;
  int size;
  creditsRoll(String message0, String message00, int size0, int y0) {
    message1 = message0;
    message2 = message00;
    size = size0;
    y = y0;
  }
  void display() {
    fill(255);
    textAlign(CENTER);
    textSize(50);
    text(message1, x, y);
    textSize(size);
    text(message2, x, y + size);
  }
  void move() {
    if(y < -size) {
      creditsCount++;
    }
    y -= count * slideSpeed;
    count++;
  }
}

// タイトル画面用のクラス
class Title {
  int x1 = width / 2;
  int y1 = height * 6 / 9;
  int x2 = width / 2;
  int y2 = height * 9 / 11;
  String start = "START";
  String exit = "EXIT";
  void display() {
    textAlign(CENTER);
    fill(0);
    if(startOrExit == 0) {
      textSize(50);
      text('→' + start, x1, y1);
      textSize(40);
      text(exit, x2, y2);
    } else if(startOrExit == 1) {
      textSize(40);
      text(start, x1, y1);
      textSize(50);
      text('→' + exit, x2, y2);
    }

  }
  void command() {
    if(key == CODED) {
      if(keyCode == UP) {
        startOrExit = 0;
      } else if(keyCode == DOWN) {
        startOrExit = 1;
      }
    }
  }
}

Text t1; // **が戦いを挑んできた!
selectText st2; // 1.たたかう 2.薬を使う
Text t3; // **は※＊を使った!
selectText st4; // 2.わざ1 1.わざ2
Text t5; // **の**!
Text t6; // 効果は今ひとつのようだ
Text t7; // 能力の効果で**は少し回復した！
Text t8; // **の**!
Text t9; // 効果はバツグン!
Text t10; // 敵の**の＊!
Text t11; // 敵の**は倒れた!
Text t12; // **はやられた!
Text t_test; // テスト用
Chara player, enemy;
Status ps, es;
Music b;
PImage back;
map m;
mapPlayer mp;
mapEnemy me;
Title t;

// 製作者
// 江刺裕太(Yuta Esashi)　　江刺裕太(Yuta Esashi)
creditsRoll cr1;

// シナリオ
// 江刺裕太(Yuta Esashi)
creditsRoll cr2;

// 音楽
// 魔王魂
creditsRoll cr3;

// デザイン
// 江刺裕太(Yuta Esashi)
creditsRoll cr4;

// タイトル
// TREASON KNIGHTHOOD
creditsRoll cr5;

void setup() {
    minim = new Minim(this);
    b = new Music();
    b.load();
    size(1200, 900); // 画面サイズ
    back = loadImage("images/背景.png");
    PFont font = createFont("HG行書体", 50);
    textFont(font);
    t1 = new Text();
    t3 = new Text();
    t5 = new Text();
    t6 = new Text();
    t7 = new Text();
    t8 = new Text();
    t9 = new Text();
    t10 = new Text();
    t11 = new Text();
    t12 = new Text();
    st2 = new selectText();
    st4 = new selectText();
    t_test = new Text();
    player = new Chara("A", "images/mapkantoku_b.png", 150, 30, 10, 20);
    enemy = new Chara("B", "images/.png", 150, 25, 20, 10);
    ps = new Status(550, 480, player.HP);
    es = new Status(100, 110, enemy.HP);
    m = new map();
    mp = new mapPlayer(7, 10, m.pixelNumber); 
    me = new mapEnemy(8, 1, m.pixelNumber); 
    cr1 = new creditsRoll("製作者", "江刺裕太(Yuta Esashi)", 40, height);
    cr2 = new creditsRoll("シナリオ", "江刺裕太(Yuta Esashi)", 60, height);
    cr3 = new creditsRoll("音楽", "魔王魂", 60, height);
    cr4 = new creditsRoll("デザイン", "江刺裕太(Yuta Esashi)", 60, height);
    cr5 = new creditsRoll("タイトル", "TREASON KNIGHTHOOD", 80, height/2 - 40);
    t = new Title();
}

void draw() {
    // 以下タイトル
    if(mapOrBattleOrCreditsRollOrTitle == 3) {
        background(255);
        t.display();
        t.command();
        DeterminationOfStartOrExit();
    }
    //ここまでタイトル

    // 以下バトル
    if(mapOrBattleOrCreditsRollOrTitle == 1) {
        image(back, 0, 0, width, height);
        transition();
        st2.command();
        st4.command();

        /* デバッグ用
        t.display(width*2/20, height * 7 / 10, width*16/20, 100, width*2/10, height * 23 / 30, 30, "テスト");
        st.display(width*10/20, height * 7 / 10, width*16/20/2, 100, width*7/10, height * 23 / 30, 30, "テスト");
        st.command();
        // ここまでデバッグ */

        /*デバッグ用
        if(st.select == 1) {
            println("1が入力されました");
        } else if(st.select == 2) {
            println("2が入力されました");
        }
        // ここまでデバッグ */

        player.display(300, 400, 200, 200);
        ps.display(player.NAME, player.HP);
        enemy.display(700, 50, 200, 200);
        es.display(enemy.NAME, enemy.HP);
        b.musicStop("field");
        if(situation == 1){
            b.playback("bgm");
        }else if(situation == 12){
            b.musicStop("bgm");
            b.playback("deth");
        }else if(situation == 11){
            b.musicStop("bgm");
            b.playback("win");
        }
        battleIsOver();
    }
    // ここまでバトル

    // 以下マップ
    if(mapOrBattleOrCreditsRollOrTitle == 0) {
        m.display();
        mp.display();
        mp.move();
        me.display();
        b.musicStop("bgm");
        b.playback("field");
        isEncounterAnEnemy();
    }
    // ここまでマップ

    // 以下エンドロール
    if(mapOrBattleOrCreditsRollOrTitle == 2) {
        frameSpeed();
        background(0);
        if(creditsCount == 1) {
            cr1.display();
            cr1.move();
        } else if(creditsCount == 2) {
            cr2.display();
            cr2.move();
        } else if(creditsCount == 3) {
            cr3.display();
            cr3.move();
        } else if(creditsCount == 4) {
            cr4.display();
            cr4.move();
        } else if(creditsCount == 5 && millis() >= 22400) {
            cr5.display();
            //cr5.move();
        }
    }
    // ここまでエンドロール
}


//チートコード
void keyPressed(){
  if(key == 'a' && enemy.HP != 0){
    enemy.HP--;
  }
  if(key == 'b' && player.HP != 0){
    player.HP--;
  }
}

// 遷移
void transition() {
    if(situation == 1) {
        t1.display(width*2/20, height * 7 / 10, width*16/20, 100, width*2/10, height * 23 / 30, 30, "野生の" +enemy.NAME + "が襲ってきた!");
        if(key == ENTER) {
            enterCheck = true;
            key = 'k';
        }
        if(enterCheck == true && keyPressed == false) {
            b.playback("push");
            enterCheck = false;
            situation = 2;
        }
    } else if(situation == 2) {
        st2.display(width*10/20, height * 7 / 10, width*16/20/2, 100, width*7/10-170, height * 23 / 30, 30, "1.たたかう　　2.薬を使う");
        //if(st2.select == 1) {
        if(key == '1') {
            b.playback("push");
            st2.select = 0;
            st4.select = 0;
            situation = 13;            
        } //else if(st2.select == 2) {
        else if(key == '2') {
            b.playback("push");
            st2.select = 0;
            st4.select = 0;
            situation = 3;
        }
    } else if(situation == 3) {
        t3.display(width*2/20, height * 7 / 10, width*16/20, 100, width*2/10, height * 23 / 30, 30, player.NAME+"は**を使って回復した!");
        if(key == ENTER) {
            enterCheck = true;
            key = 'k';
        }
        if(enterCheck == true && keyPressed == false) {
            b.playback("push");
            enterCheck = false;
            if(player.HP + 20 >= player.HP_max) {
                b.playback("heal");
                player.HP = player.HP_max;
            } else {
                b.playback("heal");
                player.HP += 20;
            }
            situation = 10;
        }
    } else if(situation == 13) {
        t1.display(width*2/20, height * 7 / 10, width*16/20, 100, width*2/10, height * 23 / 30, 30, player.NAME+"はたたかう決意をした!");
        if(key == ENTER) {
            enterCheck = true;
            key = 'k';
        }
        if(enterCheck == true && keyPressed == false) {
            b.playback("push");
            enterCheck = false;
            situation = 4;
        }
    }else if(situation == 4) {
        st4.display(width*10/20, height * 7 / 10, width*16/20/2, 100, width*7/10-100, height * 23 / 30, 30, "1.技1　　2.技2");
        //if(st4.select == 1) {
        if(key == '1') {
            b.playback("push");
            st2.select = 0;
            st4.select = 0;
            situation = 5;
        } // else if(st4.select == 2) {
        else if(key == '2') {
            b.playback("push");
            st2.select = 0;
            st4.select = 0;
            situation = 8;
        }
    } else if(situation == 5) {
        t5.display(width*2/20, height * 7 / 10, width*16/20, 100, width*2/10, height * 23 / 30, 30, player.NAME+"の**!");
        if(key == ENTER) {
            enterCheck = true;
            key = 'k';
        }
        if(enterCheck == true && keyPressed == false) {
            b.playback("push");
            enterCheck = false;
            if( enemy.HP - 20 <= 0) {
                b.playback("attack");
                enemy.HP = 0;
            } else {
                b.playback("attack");
                enemy.HP -= 20;
            }
            if(player.HP + 20 >= player.HP_max) {
                b.playback("heal");
                player.HP = player.HP_max;
            } else {
                b.playback("heal");
                player.HP += 20;
            }
            situation = 6;
        }
    } else if(situation == 6) {
        t6.display(width*2/20, height * 7 / 10, width*16/20, 100, width*2/10, height * 23 / 30, 30, "効果は今ひとつのようだ!");
        if(key == ENTER) {
            enterCheck = true;
            key = 'k';
        }
        if(enterCheck == true && keyPressed == false) {
            b.playback("push");
            enterCheck = false;
            situation = 7;
        }
    } else if(situation == 7) {
        t7.display(width*2/20, height * 7 / 10, width*16/20, 100, width*2/10, height * 23 / 30, 30, "能力の効果で"+player.NAME+"は少し回復した!");
        if(key == ENTER) {
            enterCheck = true;
            key = 'k';
        }
        if(enterCheck == true && keyPressed == false) {
            b.playback("push");
            enterCheck = false;
            if(enemy.HP == 0) { // 敵が死んだら
                b.playback("explo");
                situation = 11;
            } else { //敵が死ななかったら
                situation = 10;
            }
        }
    } else if(situation == 8) {
        t8.display(width*2/20, height * 7 / 10, width*16/20, 100, width*2/10, height * 23 / 30, 30, player.NAME+"の**!");
        if(key == ENTER) {
            enterCheck = true;
            key = 'k';
        }
        if(enterCheck == true && keyPressed == false) {
            b.playback("push");
            enterCheck = false;
            if( enemy.HP - 20 <= 0) {
                b.playback("attack");
                enemy.HP = 0;
            } else {
                b.playback("attack");
                enemy.HP -= 20;
            }
            situation = 9;
        }
    } else if(situation == 9) {
        t9.display(width*2/20, height * 7 / 10, width*16/20, 100, width*2/10, height * 23 / 30, 30, "効果はバツグン");
        if(key == ENTER) {
            enterCheck = true;
            key = 'k';
        }
        if(enterCheck == true && keyPressed == false) {
            b.playback("push");
            enterCheck = false;
            if(enemy.HP == 0) { //敵が死んだら
                b.playback("explo");
                situation = 11;
            } else { //敵が死ななかったら
                situation = 10;
            }
        }
    } else if(situation == 10) {
        t10.display(width*2/20, height * 7 / 10, width*16/20, 100, width*2/10, height * 23 / 30, 30, "敵の"+enemy.NAME+"の**!");
        if(key == ENTER) {
            enterCheck = true;
            key = 'k';
        }
        if(enterCheck == true && keyPressed == false) {
            b.playback("push");
            enterCheck = false;
            if( player.HP - 20 <= 0) {
                b.playback("attack");
                player.HP = 0;
            } else {
                b.playback("attack");
                player.HP -= 20;
            }
            if(player.HP != 0) { // 自分が生きてたら
                situation = 2;
            } else { // 自分が死んだら
                situation = 12;
            }
        }
    } else if(situation == 11) {
        t11.display(width*2/20, height * 7 / 10, width*16/20, 100, width*2/10, height * 23 / 30, 30, "敵の"+enemy.NAME+"は倒れた!");
        if(key == ENTER) {
                enterCheck = true;
                key = 'k';
            }
            if(enterCheck == true && keyPressed == false) {
                b.playback("push");
                enterCheck = false;
                situation = 0;
            }
    } else if(situation == 12) {
        t12.display(width*2/20, height * 7 / 10, width*16/20, 100, width*2/10, height * 23 / 30, 30, player.NAME+"はやられた!");
        if(key == ENTER) {
                enterCheck = true;
                key = 'k';
            }
            if(enterCheck == true && keyPressed == false) {
                b.playback("push");
                enterCheck = false;
                situation = 0;
            }
    } else if(situation == 0){
        t_test.display(width*2/20, height * 7 / 10, width*16/20, 100, width*2/10, height * 23 / 30, 30, "終了、本来はこの画面は出ません");
    }
}

//閉じたときに音楽ファイルを停止する関数
void stop(){
    b.end();
    minim.stop();
    super.stop();
}

// 敵と遭遇したかどうかを判定し、シチュエーションを変更する関数
void isEncounterAnEnemy() {
    if(mp.i == me.i && mp.j == me.j) {
        mapOrBattleOrCreditsRollOrTitle = 1;
    }
}

// フレーム速度を変則的にするための関数
void frameSpeed() {
    frameRate(10);
}

// バトルが終わったかどうかを判定するための関数
void battleIsOver() {
    if(situation == 0) {
        mapOrBattleOrCreditsRollOrTitle = 2;
    }
}

// STARTとEXITどちらを選んだかを判定する関数
void DeterminationOfStartOrExit() {
    if(key == ENTER) {
        enterCheck = true;
        key = 'k';
    }
    if(enterCheck == true && keyPressed == false) {
        if(startOrExit == 0) {
            enterCheck = false;
            mapOrBattleOrCreditsRollOrTitle = 0;
        } else if(startOrExit == 1) {
            exit();
        }
    }
}
