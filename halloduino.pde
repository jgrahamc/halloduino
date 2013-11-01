// halloduino.pde - simple program to produce random Hallowe'en
// lighting effects for a light inside a can.
//
// Uses an LPD8806-based lighting strip from Adafruit
//
// Copyright (c) 2013 John Graham-Cumming

#include "LPD8806.h"
#include "SPI.h"

// The number of LEDs on the strip
#define LED_COUNT 12

// The pins used to access the strip. These will depend on the
// specific Arduino being used.
#define DATA_PIN  2
#define CLOCK_PIN 1

LPD8806 strip = LPD8806(LED_COUNT, DATA_PIN, CLOCK_PIN);

struct _rgb {
  int r, g, b;
};

// Colors used for the various effects. These were chosen with some
// manual fiddling to look 'spooky'. 

struct _rgb blood   = {0xFF, 0x00, 0x00}; // Red
struct _rgb ghost   = {0xFF, 0xFF, 0xFF}; // White
struct _rgb pumpkin = {0xFF, 0x91, 0x00}; // Orange pumpkin color
struct _rgb purple  = {0x46, 0x06, 0x45}; // Purple 'witch' color
struct _rgb green   = {0x02, 0xA5, 0x02}; // Green 'witch' color
struct _rgb bat     = {0x00, 0x00, 0x00}; // Black

// all: set the entire strip to use a single color
void all(struct _rgb c) {
  for (int i = 0; i < strip.numPixels(); i++) {
    strip.setPixelColor(i, c.r, c.g, c.b);
  }
  
  strip.show();
}

// Functions to set specific colors
void show_blood()   { all(blood);   delay(5000); }
void show_ghost()   { all(ghost);   delay(5000); }
void show_pumpkin() { all(pumpkin); delay(5000); }
void show_purple()  { all(purple);  delay(5000); }
void show_green()   { all(green);   delay(5000); }
void show_bat()     { all(bat);     delay(5000); }

// alternate: alternate between two colors
void alternate(struct _rgb first, struct _rgb second) {
  for (int i = 0; i < 20; i++) {
     all(first);
     delay(random(120,180));
     all(second);
     delay(random(130,190));
  }
  
  all(bat);
}

// Functions to alternate between colors
void green_purple()   { alternate(green, purple);  }
void green_blood()    { alternate(green, blood);   }
void purple_blood()   { alternate(purple, blood);  }

struct _frgb {
  float r, g, b;
};

// fade: fade between two colors
void fade(struct _rgb in, struct _rgb out) {
  
  // Number of fading steps and the number of milliseconds over 
  // which to fade
  
  int steps = 200;
  int time = 400;
  
  struct _frgb c = {in.r, in.g, in.b};
  struct _frgb d;
  d.r = ((float)out.r - (float)in.r)/(float)steps;
  d.g = ((float)out.g - (float)in.g)/(float)steps;
  d.b = ((float)out.b - (float)in.b)/(float)steps;
  
  for (int i = 0; i < steps; i++) {
    struct _rgb ci;
    ci.r = c.r;
    ci.g = c.g;
    ci.b = c.b;
    all(ci);
    
    c.r += d.r;
    c.g += d.g;
    c.b += d.b;
    
    delay(time/steps);
  }
}

// Functions to fade between colors

void purple_to_blood() { fade(purple, blood); }
void purple_to_green() { fade(purple, green); }
void blood_to_green()  { fade(blood,  green); }

// Generate a lightning effect with a sequence of rapid
// white flashes
int lightning_delay(int t) {
  while (t > 0) {
    delay(random(30,60));
    t -= 1;
  }
}
void lightning() {
  all(bat);
  for (int i = 0; i < 4; i++) {
    all(ghost);
    lightning_delay(1);
    all(bat);
    lightning_delay(2);
  }
}

// Table of possible effects that are used. Add entries to this table
// to have the program randomnly choose that effect.
void (*effects[])() = {lightning, green_purple, show_bat, show_purple,
  show_green, show_ghost, green_blood, purple_blood, purple_to_blood,
  purple_to_green, blood_to_green, show_pumpkin, lightning, lightning};

void setup() {
  randomSeed(analogRead(0));
  strip.begin();
  strip.show();
}

// Chooses a random effect and calls its function
void loop() {
  effects[random(0, sizeof(effects)/sizeof(effects[0]))]();
}

