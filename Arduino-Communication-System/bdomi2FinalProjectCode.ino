/*
Names, NetIDs, emails:
Jackson LeJeune, jleje2, jleje2@uic.edu
Dean Tubongbanua, dtubon2, dtubon2@uic.edu
Alec Sanders, asand41, asand41@uic.edu
Bryan Dominguez, bdomi2, bdomi2@uic.edu


Group Number: 22
Project Name: Arduino Telegraph
Project Abstract: Using Arduino boards, LCD screens, LoRa radio transceivers, and a few
buttons, we will create a system that, given input of dots and dashes, will send an encoded
message to other Arduino boards, using radio signals, that will decode the message and display it
on an LCD screen. Users will select specific “channels” to broadcast to using a joystick, and any
other Arduinos on that channel will receive any message broadcasted on it.
*/


//INCLUDES & DEFINITIONS--------------------------------------------------------------
//Imports LCD library, sets up the LCD screen with according pin numbers
#include <LiquidCrystal.h>
#include <LiquidCrystal_I2C.h>
#define VRX_PIN A0
#define VRY_PIN A1


//huffman codec, map, vector and queue Libraries (for encoding/decoding/message queue)
#define HUFFMAN_CODEC_H
#include <Arduino.h>
#include <map>
#include <queue>
#include <vector>


//LoRa serial setup--------------------------------------------------------------
//uses software serial for R4/R3 and serial1 for MEGA
#if defined(__AVR_ATmega2560__)
#define LoRaSerial Serial1
#else
#include <SoftwareSerial.h>
#define LORA_RX 6
#define LORA_TX 7
SoftwareSerial LoRaSerial(LORA_RX, LORA_TX);
#endif


//LCD setup
LiquidCrystal_I2C lcd(0x27, 16, 2);


//Digital pins for button input--------------------------------------------------------------
const int dotPin = 8;
const int dashPin = 9;
const int spacePin = 11;
const int clearPin = 12;
const int sendPin = 13;


//State/message waiting declarations--------------------------------------------------------------------------
std::queue<String> messageQueue;
bool draftState = false;
bool playBackState = false;
bool readyState = true;
bool messageWaiting = false;


// Scrolling message variables--------------------------------------------------------------
char scrolledMessage[128] = " ";  //Buffer to hold message
int scrollPosition = 0;
unsigned long lastScrollTime = 0;
const int scrollDelay = 300;
int scrolledMessageLength = 0;
bool newMessageReady = false;


//OUTPUT VARIABLES-------------------------------------------------------------------------
const int ledPin = 2;
const int buzzerPin = 3;
const int potPin = A2;


// Button/debounce variables--------------------------------------------------------------
bool dotPressed = false;
bool dashPressed = false;
bool spacePressed = false;
bool clearPressed = false;
bool sendPressed = false;


//Debouncing for each button
//Changed to address inconsistent debounce with fast button presses
unsigned long prevDebounceDot = 0;
unsigned long prevDebounceDash = 0;
unsigned long prevDebounceSpace = 0;
unsigned long prevDebounceClear = 0;
unsigned long prevDebounceSend = 0;
const unsigned long debounceDelay = 200;  // extended debounce delay to improve consistency


//JOYSTICK VARIABLES--------------------------------------------------------------
//It is worth noting that due to the position of the joystick in the breadboard, the y axis is the left and right inputs (positive y = left, and negative y = right), and "up" is positive x
const int joystickDPin = 7;
int joystickX = 0;
int joystickY = 0;
bool joystickMoved = false;


//7-Segment display variables--------------------------------------------------------------
//Pins for 7-segment output
const int latchPin = 0;
const int clockPin = 1;
const int dataPin = 4;


int leds = 0;
int prevLeds = 0;
int displayChannel = 0;
int lastDisplayChannel = -1;
float channelMHz = 915.0;


//Parallel arrays for morse-to-char functionality
char morseMap[51][7] = { ".-    ", "-...  ", "-.-.  ", "-..   ", ".     ", "..-.  ", "--.   ", "....  ", "..    ", ".---  ",
                         "-.-   ", ".-..  ", "--    ", "-.    ", "---   ", ".--.  ", "--.-  ", ".-.   ", "...   ", "-     ",
                         "..-   ", "...-  ", ".--   ", "-..-  ", "-.--  ", "--..  ", "----- ", ".---- ", "..--- ", "...-- ",
                         "....- ", "..... ", "-.... ", "--... ", "---.. ", "----. ", ".-... ", ".--.-.", "-.--.-", "-.--. ",
                         "---...", "--..--", "-...- ", "-.-.--", ".-.-.-", "-....-", "-..-  ", ".-.-. ", ".-..-.", "..--..", "-..-." };
char charMap[51] = { 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
                     'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
                     'U', 'V', 'W', 'X', 'Y', 'Z', '0', '1', '2', '3',
                     '4', '5', '6', '7', '8', '9', '&', '@', ')', '(',
                     ':', ',', '=', '!', '.', '-', '*', '+', '"', '?', '/' };


//LCD display strings: top line shows morse input, bottom shows message being written
char sendMessageLine[18] = "                \0";
char prevSendMessageLine[18] = "                \0";


//Holds current morse character
char morseToCharArray[7] = "      ";


//Cursor positions
int messageCursorPos = 0;
int morseCodePos = 0;


//Message state
bool messageSent = false;




///////////////////////////////HELPER FUNCTIONS///////////////////////////////////




//--LCD AND DISPLAY FUNCTIONS--//




//prepares messages to be scrolled
void prepareScrollMessage(String message) {
  // strip prefix and suffix
  if (message.startsWith("<") && message.endsWith(">")) {
    message = message.substring(1, message.length() - 1);
  }
  message.toCharArray(scrolledMessage, sizeof(scrolledMessage));
  scrolledMessageLength = strlen(scrolledMessage);


  // Pad with spaces to mark end
  strcat(scrolledMessage, "                ");
  scrolledMessageLength = strlen(scrolledMessage);


  scrollPosition = 0;
  newMessageReady = true;


  lcd.clear();
  lcd.setCursor(3, 0);  // Top line header
  lcd.print("INCOMING:");
  Serial.print("Incoming plain text: ");
  Serial.println(message);
}


//helper function to scroll message
void scrollReceivedMessage() {
  if (!newMessageReady) return;
  if (millis() - lastScrollTime >= scrollDelay) {
    lastScrollTime = millis();
    lcd.setCursor(0, 1);
    for (int i = 0; i < 16; i++) {
      int charIndex = (scrollPosition + i) % scrolledMessageLength;
      lcd.print(scrolledMessage[charIndex]);
    }
    scrollPosition++;
    if (scrollPosition >= scrolledMessageLength) {
      scrollPosition = 0;
    }
  }
}


//helper function to reset LCD
void resetLCD() {
  messageCursorPos = 0;
  morseCodePos = 0;
  lcd.clear();
  lcd.setCursor(0, 1);
  Serial.println("LCD reset.");
}


void showReadyPrompt() {
  newMessageReady = false;
  lcd.clear();
  lcd.setCursor(0, 0);
  Serial.println("In ready state,");
  lcd.print("Ready for input!");
}




//--BUTTON FUNCTIONS--//




//Handle input from buttons: adds dots/dashes, space, clear, or sends full message
void buttonInput(char c) {
  if (!draftState && readyState && !playBackState && (c == '.' || c == '-')) {
    draftState = true;
    readyState = false;
    newMessageReady = false;  // stop prev scroll
  }
  // Block dot/dash input while in playback
  if (playBackState && (c == '.' || c == '-' || c == ' ')) {
    Serial.println("Drafting input ignored — still in playback mode.");
    return;
  }


  if (messageSent) {
    for (int i = 0; i < 16; i++) {
      sendMessageLine[i] = ' ';
    }
    messageCursorPos = 0;
    messageSent = false;
  }


  // handle dot
  if (c == '.') {
    if (morseCodePos < 6) {
      morseToCharArray[morseCodePos] = '.';
      morseCodePos++;
      sendMessageLine[messageCursorPos] = mapMorseCode();
    } else {
      sendMessageLine[messageCursorPos] = '#';
      messageCursorPos++;
      for (int i = 0; i < 6; i++) { morseToCharArray[i] = ' '; }
      morseCodePos = 0;
    }
  }


  //handle dash
  else if (c == '-') {
    if (morseCodePos < 6) {
      morseToCharArray[morseCodePos] = '-';
      morseCodePos++;
      sendMessageLine[messageCursorPos] = mapMorseCode();
    } else {
      sendMessageLine[messageCursorPos] = '#';
      for (int i = 0; i < 6; i++) { morseToCharArray[i] = ' '; }
      morseCodePos = 0;
    }
  }


  //handle space
  else if (c == ' ') {
    if (morseToCharArray[0] == ' ') {
      sendMessageLine[messageCursorPos] = ' ';
      messageCursorPos++;
    } else {
      messageCursorPos++;
      morseCodePos = 0;
      for (int i = 0; i < 6; i++) { morseToCharArray[i] = ' '; }
    }
  }


  //handle clear
  else if (c == '_') {
    // erase full Morse buffer if currently entering a letter
    if (morseCodePos > 0) {
      morseCodePos = 0;
      for (int i = 0; i < 6; i++) morseToCharArray[i] = ' ';
      if (messageCursorPos < 16) {
        sendMessageLine[messageCursorPos] = ' ';  // Clear character preview
      }
    }


    // if Morse buffer is empty, remove last entered letter
    else if (morseToCharArray[0] == ' ' && messageCursorPos > 0) {
      messageCursorPos--;
      sendMessageLine[messageCursorPos] = ' ';
    }


    // check if the entire input is now empty — return to ready state
    bool morseEmpty = true;
    for (int i = 0; i < 6; i++) {
      if (morseToCharArray[i] != ' ') {
        morseEmpty = false;
        break;
      }
    }


    bool messageEmpty = true;
    for (int i = 0; i < 16; i++) {
      if (sendMessageLine[i] != ' ') {
        messageEmpty = false;
        break;
      }
    }


    //return to ready state if clear is pressed and draft is empty
    if (draftState && morseEmpty && messageEmpty) {
      Serial.println("Cleared all input — returning to ready state.");
      draftState = false;
      readyState = true;
      showReadyPrompt();
      newMessageReady = false;
    }


    // Case 4: Update LCD unless we're back in ready state
    if (!readyState) {
      lcd.clear();
      lcd.setCursor(0, 0);
      lcd.print(morseToCharArray);
      Serial.print("LCD displaying: ");
      Serial.println(morseToCharArray);
      lcd.setCursor(0, 1);
      lcd.print(sendMessageLine);
      Serial.print("LCD displaying: ");
      Serial.println(sendMessageLine);
    }
  }


  //handle send
  else if (c == '+') {
    String plainText = String(sendMessageLine);
    plainText.trim();
    // If it starts with '!', treat it as a command — send as-is
    if (plainText.startsWith("!")) {
      Serial.print("Sending Command: ");
      Serial.println(plainText);
      LoRaSerial.println(plainText);
    } else {
      // Wrap text with < and > as "<message>" to distinguish from UART/RF noise
      String wrapped = "<" + plainText + ">";
      // Encode as Huffman binary string
      String encoded = huffmanEncode(wrapped);
      Serial.print("Outgoing plain text: ");
      Serial.println(plainText);
      Serial.print("Outgoing binary string: ");
      Serial.println(encoded);
      LoRaSerial.println(encoded);
    }


    // Clear buffers and reset
    for (int i = 0; i < 6; i++) morseToCharArray[i] = ' ';
    for (int i = 0; i < 16; i++) sendMessageLine[i] = ' ';
    resetLCD();
    messageSent = true;
  }


  // LCD redraw, unless in ready state
  if (!readyState) {
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print(morseToCharArray);
    Serial.print("LCD displaying: ");
    Serial.println(morseToCharArray);
    lcd.setCursor(0, 1);
    lcd.print(sendMessageLine);
    Serial.print("LCD displaying: ");
    Serial.println(sendMessageLine);
  }
}


//helper for state dependent send press
void handleSendPress() {
  if (draftState) {
    buttonInput('+');
    draftState = false;
    readyState = true;
    showReadyPrompt();


  } else if (playBackState) {
    if (!messageQueue.empty()) {
      String encoded = messageQueue.front();
      messageQueue.pop();


      String decoded = huffmanDecode(encoded);
      prepareScrollMessage(decoded);


      if (messageQueue.empty()) {
        messageWaiting = false;
        leds &= 0b01111111;  // Turn off DP segment
        updateShiftRegister();
      }
    } else {
      // No more messages in queue
      newMessageReady = false;
      lcd.clear();
      lcd.setCursor(2, 0);
      lcd.print("END OF MESSAGES");
      lcd.setCursor(0, 1);
      lcd.print("Press Clear...");


      Serial.println("No more messages. Displayed END OF MESSAGES.");
    }
  } else if (messageWaiting && readyState) {
    readyState = false;
    playBackState = true;


    if (!messageQueue.empty()) {
      String encoded = messageQueue.front();
      messageQueue.pop();


      String decoded = huffmanDecode(encoded);
      prepareScrollMessage(decoded);


      if (messageQueue.empty()) {
        messageWaiting = false;
        leds = prevLeds;
        updateShiftRegister();
      }
    }
  }
}


bool debouncedPress(int pin, bool& pressed, unsigned long& lastPressTime) {
  if (digitalRead(pin) == HIGH) {
    if (!pressed && millis() - lastPressTime > debounceDelay) {
      pressed = true;
      lastPressTime = millis();
      return true;
    }
  } else {
    pressed = false;
  }
  return false;
}




//--7-SEG FUNCTIONS--//




//Update the seven-segment display with the number functions.
//implementation based on post on arduino forum: https://forum.arduino.cc/t/7-segment-display-with-shift-register-74hc595-and-press-button/582423/5
void updateSevenSeg(int channel) {
  // Shift register terminals/segments:
  // Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7
  // D   B   A   E   F   G   C   DP(N/A)
  const byte segmentMap[10] = {
    0b01011111,  // 0 = A B C D E F
    0b01000010,  // 1 = B C
    0b00101111,  // 2 = A B D E G
    0b01100111,  // 3 = A B C D G
    0b01110010,  // 4 = B C F G
    0b01110101,  // 5 = A C D F G
    0b01111101,  // 6 = A C D E F G
    0b01000110,  // 7 = A B C
    0b01111111,  // 8 = A B C D E F G
    0b01110111   // 9 = A B C D F G
  };
  if (channel >= 0 && channel <= 9) {
    leds = segmentMap[channel];
    prevLeds = leds;
  } else {
    leds = 0;
  }
  updateShiftRegister();
}


//Functions to display numbers on the seven-segment
//Code provided from here: https://projecthub.arduino.cc/ratack0/seven-segment-display-with-a-74hc595-shift-register-2592a3#section0
void updateShiftRegister() {
  digitalWrite(latchPin, LOW);
  // set the latch pin to low so that the 74HC595 can receive data
  shiftOut(dataPin, clockPin, MSBFIRST, leds);
  //write the byte leds to the register
  digitalWrite(latchPin, HIGH);
  //set latch pin back to high
}




//--ENCODING/DECODING FUNCTIONS--//




//Maps morse code to a character
char mapMorseCode() {
  if (morseToCharArray[0] == ' ') {
    return ' ';
  }
  for (int i = 0; i < 51; i++) {
    if (strcmp(morseToCharArray, morseMap[i]) == 0) {
      return charMap[i];
    }
  }
  return '#';
}


//Node struct for huffman tree
struct HuffNode {
  char c;
  unsigned freq;
  HuffNode *left, *right;


  HuffNode(char c, unsigned freq)
    : c(c), freq(freq), left(nullptr), right(nullptr) {}
};


//Compare for priority queue
struct Compare {
  bool operator()(HuffNode* l, HuffNode* r) {
    return l->freq > r->freq;
  }
};


//Freq map (based on avg frequency of english characters)
std::map<char, unsigned> freqMap = {
  { 'E', 127 }, { 'T', 91 }, { 'A', 82 }, { 'O', 75 }, { 'I', 70 }, { 'N', 67 },
  { 'S', 63 }, { 'H', 61 }, { 'R', 60 }, { 'D', 43 }, { 'L', 40 }, { 'C', 28 },
  { 'U', 28 }, { 'M', 24 }, { 'W', 24 }, { 'F', 22 }, { 'G', 20 }, { 'Y', 20 },
  { 'P', 19 }, { 'B', 15 }, { 'V', 10 }, { 'K', 8 }, { 'X', 2 }, { 'Q', 1 },
  { 'J', 1 }, { 'Z', 1 }, { '0', 5 }, { '1', 5 }, { '2', 5 }, { '3', 5 },
  { '4', 5 }, { '5', 5 }, { '6', 5 }, { '7', 5 }, { '8', 5 }, { '9', 5 },
  { '.', 10 }, { ',', 8 }, { '?', 6 }, { '!', 6 }, { '-', 6 }, { '=', 4 },
  { '(', 2 }, { ')', 2 }, { ':', 2 }, { '+', 2 }, { '/', 2 }, { '&', 1 },
  { '@', 1 }, { '"', 1 }, { ' ', 120 }, { '<', 100 }, { '>', 100 }
};


// Code maps
std::map<char, String> codeTable;
std::map<String, char> decodeTable;


// build code table
void buildCodeTable(HuffNode* root, String code = "") {
  if (!root) return;
  if (!root->left && !root->right) {
    codeTable[root->c] = code;
    decodeTable[code] = root->c;
    return;
  }
  buildCodeTable(root->left, code + "0");
  buildCodeTable(root->right, code + "1");
}


//initialize huffman encoding
void initHuffman() {
  std::priority_queue<HuffNode*, std::vector<HuffNode*>, Compare> pq;
  for (auto& pair : freqMap)
    pq.push(new HuffNode(pair.first, pair.second));


  while (pq.size() > 1) {
    HuffNode* left = pq.top();
    pq.pop();
    HuffNode* right = pq.top();
    pq.pop();
    HuffNode* merged = new HuffNode('\0', left->freq + right->freq);
    merged->left = left;
    merged->right = right;
    pq.push(merged);
  }


  buildCodeTable(pq.top());
}


// Encode/Decode
String huffmanEncode(String input) {
  String output = "";
  input.toUpperCase();
  for (char c : input) {
    if (codeTable.count(c)) {
      output += codeTable[c];
    }
  }
  return output;
}


String huffmanDecode(String binary) {
  String decoded = "", current = "";
  for (char b : binary) {
    current += b;
    if (decodeTable.count(current)) {
      decoded += decodeTable[current];
      current = "";
    }
  }
  return decoded;
}




////////////////////////////////SETUP/////////////////////////////////////////




//Arduino setup: initialize LCD, buttons, and LoRa serial
void setup() {
  Serial.begin(9600);
  //initialize LoRa for UART communication
  LoRaSerial.begin(9600);


  //initialize LCD
  lcd.init();
  lcd.backlight();
  lcd.print("Ready for input!");
  Serial.println("LCD displaying: Ready for input!");
  readyState = true;
  lcd.setCursor(0, 1);
  lcd.print(" ");
  Serial.print("LCD displaying whitespace on (0, 1).");


  //initialize buttons as inputs
  pinMode(dotPin, INPUT);
  pinMode(dashPin, INPUT);
  pinMode(spacePin, INPUT);
  pinMode(clearPin, INPUT);
  pinMode(sendPin, INPUT);


  pinMode(ledPin, OUTPUT);
  pinMode(buzzerPin, OUTPUT);


  //Set up pins for 7-seg output
  pinMode(latchPin, OUTPUT);
  pinMode(clockPin, OUTPUT);
  pinMode(dataPin, OUTPUT);
  leds = 0;
  updateShiftRegister();
  LoRaSerial.println("!CH915.0");
  displayChannel = 0;
  updateSevenSeg(0);
  initHuffman();
}


//Main loop: scans buttons, handles debounce, and checks LoRa UART input
void loop() {
  //Debounce dot
  if (debouncedPress(dotPin, dotPressed, prevDebounceDot)) {
    Serial.println("dot");
    buttonInput('.');
  }


  //Debounce dash
  if (debouncedPress(dashPin, dashPressed, prevDebounceDash)) {
    Serial.println("dash");
    buttonInput('-');
  }


  //Debounce space
  if (debouncedPress(spacePin, spacePressed, prevDebounceSpace)) {
    Serial.println("space");
    buttonInput(' ');
  }


  //Debounce clear
  if (debouncedPress(clearPin, clearPressed, prevDebounceClear)) {
    Serial.println("clear");
    buttonInput('_');
    if (playBackState) {
      playBackState = false;
      readyState = true;
      newMessageReady = false;
      showReadyPrompt();
    }
  }


  //Debounce Send
  if (debouncedPress(sendPin, sendPressed, prevDebounceSend)) {
    Serial.println("send");
    handleSendPress();
  }


  //buzzer logic
  if (digitalRead(dotPin) == HIGH || digitalRead(dashPin) == HIGH || digitalRead(spacePin) == HIGH ||
      digitalRead(clearPin) == HIGH || digitalRead(sendPin) == HIGH) {
    // play buzzer/flash LED when button is pressed
    int potValue = analogRead(potPin);
    int volume = map(potValue, 0, 1023, 0, 255); // map analog reading to PWM duty cycle range
    analogWrite(buzzerPin, volume);
    digitalWrite(ledPin, HIGH);
  } else {
    // turn off buzzer/LED when button is depressed
    digitalWrite(ledPin, LOW);
    analogWrite(buzzerPin, 0);
  }


  //Check for messages from LoRa,
  //If not response to command, display message to LCD and scroll
  // Persistent buffer to store incoming characters
  static String buffer = "";


  // Process all available incoming characters
  while (LoRaSerial.available()) {
    char c = LoRaSerial.read();


    if (c == '\n') {
      // We received a complete line
      String received = buffer;
      buffer = "";  // Clear buffer for next message
      received.trim();


      if (received.length() > 0) {
        if (received.startsWith("!")) {
          String cmdID = received.substring(1, 3);  // 2-char command ID (e.g. "CH")
          String cmdArg = received.substring(3);    // Argument (e.g. "915.2")


          // Change Channel
          if (cmdID == "CH") {
            channelMHz = cmdArg.toFloat();                      // Convert to float
            displayChannel = (channelMHz - 915.0) / 0.2 + 0.5;  // Round to index
            updateSevenSeg(displayChannel);
          }
          // maybe add more commands here
        } else {
          // Otherwise treat it as a message.
          // Validate by looking for encoded '<' prefix and '>' suffix
          String prefix = codeTable['<'];
          String suffix = codeTable['>'];
          if (received.startsWith(prefix) && received.endsWith(suffix)) {
            messageQueue.push(received);
            messageWaiting = true;
            //Update DP (Q7) to indicate message waiting.
            leds |= 0b10000000;
            updateShiftRegister();
          } else {
            Serial.println("Rejected incoming Message: Invalid format or encoding.");
          }
        }
      }
    } else {
      // Append character to ongoing buffer
      buffer += c;
    }
  }


  // Keep scrolling incoming messages unless ready state is triggered
  if (!readyState && newMessageReady) {
    scrollReceivedMessage();
  }


  //Joystick input: if the joystick is moved left or right enough, it will change the channel and the seven segment display
  joystickY = analogRead(VRY_PIN);
  if ((abs(joystickY - 516) > 300) && !joystickMoved) {
    joystickMoved = true;
    if (((joystickY - 500) > 0) && displayChannel > 0) {
      LoRaSerial.println("!CH" + String(channelMHz - 0.2, 1));
      Serial.println("Joystick triggered.");
    } else if (((joystickY - 500) < 0) && displayChannel < 9) {
      LoRaSerial.println("!CH" + String(channelMHz + 0.2, 1));
      Serial.println("Joystick triggered.");
    }
  }
  //If the joystick is returned to its neutral position, allow another input to be made
  if (abs(joystickY - 516) <= 20) {
    joystickMoved = false;
  }


  //Needs to be called constantly to keep display on, if called once, doesn't store the value
  if (displayChannel != lastDisplayChannel) {
    updateSevenSeg(displayChannel);
    lastDisplayChannel = displayChannel;
  }
}