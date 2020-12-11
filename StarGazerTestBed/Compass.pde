/*
    LIS3MDL Compass Module from Adafruit
    I2C Address: 0x1C
    
    
*/

final int DRDY = 16;  // data ready pin
int mX,mY,mZ,cTemp;

final byte compassAddress = 0x1C; ///< Default breakout addres
/*=========================================================================*/

final byte LIS3MDL_REG_WHO_AM_I = 0x0F;  ///< Register that contains the part ID
final byte LIS3MDL_REG_CTRL_REG1 = 0x20; ///< Register address for control 1
final byte LIS3MDL_REG_CTRL_REG2 = 0x21; ///< Register address for control 2
final byte LIS3MDL_REG_CTRL_REG3 = 0x22; ///< Register address for control 3
final byte LIS3MDL_REG_CTRL_REG4 = 0x23; ///< Register address for control 3
final byte LIS3MDL_REG_STATUS_REG = 0x27;///< Register address for data ready|overrun
final byte LIS3MDL_REG_OUT_X_L = 0x28;   ///< Register address for X axis lower byte
final byte LIS3MDL_REG_OUT_Y_L = 0x2A;  
final byte LIS3MDL_REG_OUT_Z_L = 0x2C;  
final byte LIS3MDL_REG_OUT_TEMP_L = 0x2E;  
final byte LIS3MDL_REG_INT_CFG = 0x30;   ///< Interrupt configuration register
final byte LIS3MDL_REG_INT_THS_L = 0x32; ///< Low byte of the irq threshold

/** The magnetometer ranges */
final byte  LIS3MDL_RANGE_4_GAUSS = 0x00;  ///< +/- 4g (default value)
final byte  LIS3MDL_RANGE_8_GAUSS = 0x01;  ///< +/- 8g
final byte  LIS3MDL_RANGE_12_GAUSS = 0x02; ///< +/- 12g
final byte  LIS3MDL_RANGE_16_GAUSS = 0x03; ///< +/- 16g

/** The magnetometer data rate, includes FAST_ODR bit */
final byte  LIS3MDL_DATARATE_0_625_HZ = 0x00;  ///<  0.625 Hz
final byte  LIS3MDL_DATARATE_1_25_HZ = 0x02;  ///<  1.25 Hz
final byte  LIS3MDL_DATARATE_2_5_HZ = 0x04;   ///<  2.5 Hz
final byte  LIS3MDL_DATARATE_5_HZ = 0x06;     ///<  5 Hz
final byte  LIS3MDL_DATARATE_10_HZ = 0x08;    ///<  10 Hz
final byte  LIS3MDL_DATARATE_20_HZ = 0x0A;    ///<  20 Hz
final byte  LIS3MDL_DATARATE_40_HZ = 0x0C;    ///<  40 Hz
final byte  LIS3MDL_DATARATE_80_HZ = 0x0E;    ///<  80 Hz
final byte  LIS3MDL_DATARATE_155_HZ = 0x01;   ///<  155 Hz (FAST_ODR + UHP)
final byte  LIS3MDL_DATARATE_300_HZ = 0x03;   ///<  300 Hz (FAST_ODR + HP)
final byte  LIS3MDL_DATARATE_560_HZ = 0x05;   ///<  560 Hz (FAST_ODR + MP)
final byte  LIS3MDL_DATARATE_1000_HZ = 0x07;  ///<  1000 Hz (FAST_ODR + LP)final byte

/** The magnetometer performance mode */
final byte  LIS3MDL_LOWPOWERMODE = 0x00;  ///< Low power mode
final byte  LIS3MDL_MEDIUMMODE = 0x01;    ///< Medium performance mode
final byte  LIS3MDL_HIGHMODE = 0x02;      ///< High performance mode
final byte  LIS3MDL_ULTRAHIGHMODE = 0x03; ///< Ultra-high performance mode

/** The magnetometer operation mode */
final byte  LIS3MDL_CONTINUOUSMODE = 0x00; ///< Continuous conversion
final byte  LIS3MDL_SINGLEMODE = 0x01;     ///< Single-shot conversion
final byte  LIS3MDL_POWERDOWNMODE = 0x02;  ///< Powered-down mode

final byte  LIS3MDL_SOFT_RESET = 0x40;

boolean initCompass(){
  boolean enabled = true; 
  if(compassReadByte(LIS3MDL_REG_WHO_AM_I) != 0x3D){
    println("initCompass ID fail");
    return false;
  }
  compassWrite(LIS3MDL_REG_CTRL_REG3,byte(0x03));
  if(compassReadByte(LIS3MDL_REG_CTRL_REG3) != 0x03){ enabled = false; }
  byte outByte;
  outByte = byte(0x80); // enable temperature sensor
  outByte |= (LIS3MDL_HIGHMODE << 5);
  outByte |= (LIS3MDL_DATARATE_2_5_HZ << 2);
  compassWrite(LIS3MDL_REG_CTRL_REG1,outByte);
  if(compassReadByte(LIS3MDL_REG_CTRL_REG1) != outByte){ enabled = false; }
  outByte = (LIS3MDL_RANGE_16_GAUSS << 5);
  compassWrite(LIS3MDL_REG_CTRL_REG2,outByte);
  if(compassReadByte(LIS3MDL_REG_CTRL_REG2) != outByte){ enabled = false; }
  //if(!startCompass()){ enabled = false; }
  
  return enabled;
}

void compassWrite(byte reg, byte data){
  println("writing 0x"+hex(data)+" to 0x"+hex(reg));
  i2c.beginTransmission(compassAddress);
  i2c.write(reg);
  i2c.write(data);
  i2c.endTransmission();
}

boolean startCompass(){
  byte outByte = 0x01;
  compassWrite(LIS3MDL_REG_CTRL_REG3,byte(outByte));
  if(compassReadByte(LIS3MDL_REG_CTRL_REG3) == outByte){
    delay(50);
    return true;
  } else {
    return false;
  }
}

boolean stopCompass(){
  byte outByte = 0x03;
  compassWrite(LIS3MDL_REG_CTRL_REG3,byte(outByte));
  if(compassReadByte(LIS3MDL_REG_CTRL_REG3) == outByte){
    return true;
  } else {
    return false;
  }
}

byte compassReadByte(byte reg){
  println("reading byte from 0x"+hex(reg));
  //try{
    i2c.beginTransmission(compassAddress);
    i2c.write(reg);
    byte b[] = i2c.read(1);
  //} catch(RuntimeException
  byte returnByte = b[0];
  return returnByte;
}

boolean checkCompassDRDY(){
  byte status = compassReadByte(LIS3MDL_REG_STATUS_REG); 
  //println("status: 0x"+hex(status));
  if(status != 0x00){
    updateCompassAxes();
    return true;
  }
  return false;
}

void updateCompassAxes(){
  mX = compassReadWord(LIS3MDL_REG_OUT_X_L);
  mY = compassReadWord(LIS3MDL_REG_OUT_Y_L);
  mZ = compassReadWord(LIS3MDL_REG_OUT_Z_L);
  cTemp = compassReadWord(LIS3MDL_REG_OUT_TEMP_L);
}

int compassReadWord(byte reg){
  println("reading word from  0x"+hex(reg));
  int i = 0;
  i2c.beginTransmission(compassAddress);
  i2c.write(reg);
  byte b[] = i2c.read(2);
  i = (b[1]<<8)|b[0];
  if((i & 0x8000) > 0){
    i |= 0xFFFF0000;
  }
  return i;
}

void printCompassAxes(){
  print("\tx: "+mX);
  print("\ty: "+mY);
  print("\tz: "+mZ);
  print("\ttemp: "+cTemp);
  println();
}
