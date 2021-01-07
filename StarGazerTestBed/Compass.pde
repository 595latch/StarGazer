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


//	CONTROL REGISTER 1  0x20
/** Temperature Control */
final byte LIS3MDL_TEMP_DISABLE = 0x00;
final byte LIS3MDL_TEMP_ENABLE = byte(0x80);

/** The magnetometer performance mode */
final byte  LIS3MDL_LOWPOWERMODE = 0x00;  ///< Low power mode
final byte  LIS3MDL_MEDIUMMODE = 0x20;    ///< Medium performance mode
final byte  LIS3MDL_HIGHMODE = 0x40;      ///< High performance mode
final byte  LIS3MDL_ULTRAHIGHMODE = 0x60; ///< Ultra-high performance mode

/** The magnetometer data rate, includes FAST_ODR bit */
final byte  LIS3MDL_DATARATE_0_625_HZ = 0x00; ///<  0.625 Hz
final byte  LIS3MDL_DATARATE_1_25_HZ = 0x02;  ///<  1.25 Hz
final byte  LIS3MDL_DATARATE_2_5_HZ = 0x04;   ///<  2.5 Hz
final byte  LIS3MDL_DATARATE_5_HZ = 0x06;     ///<  5 Hz
final byte  LIS3MDL_DATARATE_10_HZ = 0x10;    ///<  10 Hz
final byte  LIS3MDL_DATARATE_20_HZ = 0x12;    ///<  20 Hz
final byte  LIS3MDL_DATARATE_40_HZ = 0x14;    ///<  40 Hz
final byte  LIS3MDL_DATARATE_80_HZ = 0x16;    ///<  80 Hz
final byte  LIS3MDL_DATARATE_155_HZ = 0x01;   ///<  155 Hz (FAST_ODR + UHP)
final byte  LIS3MDL_DATARATE_300_HZ = 0x03;   ///<  300 Hz (FAST_ODR + HP)
final byte  LIS3MDL_DATARATE_560_HZ = 0x05;   ///<  560 Hz (FAST_ODR + MP)
final byte  LIS3MDL_DATARATE_1000_HZ = 0x07;  ///<  1000 Hz (FAST_ODR + LP)final byte

//	CONTROL REGISTER 2	0x21
/** The magnetometer ranges */
final byte  LIS3MDL_RANGE_4_GAUSS = 0x00;  ///< +/- 4g (default value)
final byte  LIS3MDL_RANGE_8_GAUSS = 0x20;  ///< +/- 8g
final byte  LIS3MDL_RANGE_12_GAUSS = 0x40; ///< +/- 12g
final byte  LIS3MDL_RANGE_16_GAUSS = 0x60; ///< +/- 16g

/** Reboot Memory Control */
final byte LIS3MDL_REBOOT_MEMORY = 0x08;

/** Soft Reset */
final byte LIS3MDL_SOFT_RESET = 0x04;

//	CONTROL REGISTER 3 0x22
/** The magnetometer operation mode */
final byte  LIS3MDL_CONTINUOUSMODE = 0x00; ///< Continuous conversion
final byte  LIS3MDL_SINGLEMODE = 0x01;     ///< Single-shot conversion
final byte  LIS3MDL_POWERDOWNMODE = 0x02;  ///< Powered-down mode


void getCompassID(){
  println("compass id: 0x"+hex(compassReadByte(LIS3MDL_REG_WHO_AM_I)));
}


boolean initCompass(){
  boolean enabled = true;
  //compassWrite(LIS3MDL_REG_CTRL_REG2,byte(0x0C));

  delay(100);
  if(compassReadByte(LIS3MDL_REG_WHO_AM_I) != 0x3D){
    println("initCompass ID fail");
    return false;
  }
  compassWrite(LIS3MDL_REG_CTRL_REG3,LIS3MDL_POWERDOWNMODE);
  if(compassReadByte(LIS3MDL_REG_CTRL_REG3) != LIS3MDL_POWERDOWNMODE){ enabled = false; }
  byte outByte = LIS3MDL_TEMP_ENABLE; // enable temperature sensor
  outByte |= (LIS3MDL_HIGHMODE);
  outByte |= (LIS3MDL_DATARATE_0_625_HZ);
  compassWrite(LIS3MDL_REG_CTRL_REG1,outByte);
  if(compassReadByte(LIS3MDL_REG_CTRL_REG1) != outByte){ enabled = false; }
  outByte = (LIS3MDL_RANGE_16_GAUSS);
  compassWrite(LIS3MDL_REG_CTRL_REG2,outByte);
  if(compassReadByte(LIS3MDL_REG_CTRL_REG2) != outByte){ enabled = false; }
  // Control Reg 3 used to enable/disable compass sampling
	println("status reg: 0x"+hex(compassReadByte(LIS3MDL_REG_STATUS_REG)));

  return enabled;
}

void compassWrite(byte reg, byte data){
  println("writing 0x"+hex(data)+" to 0x"+hex(reg));
  iic.beginTransmission(compassAddress);
  iic.write(reg);
  iic.write(data);
  iic.endTransmission();
}

boolean startCompass(){
  compassWrite(LIS3MDL_REG_CTRL_REG3,LIS3MDL_SINGLEMODE);
  // if(compassReadByte(LIS3MDL_REG_CTRL_REG3) == LIS3MDL_SINGLEMODE){
    // delay(50);
    return true;
  // } else {
    // return false;
  // }
}

boolean stopCompass(){
  compassWrite(LIS3MDL_REG_CTRL_REG3,LIS3MDL_POWERDOWNMODE);
  // if(compassReadByte(LIS3MDL_REG_CTRL_REG3) == LIS3MDL_POWERDOWNMODE){
    return true;
  // } else {
    // return false;
  // }
}

byte compassReadByte(byte reg){
  println("reading byte from 0x"+hex(reg));
  iic.beginTransmission(compassAddress);
  iic.write(reg);
  byte b[] = iic.read(1);
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
  byte b = compassReadByte(reg);
  i = b & 0xFF;
  reg++;
  b = compassReadByte(reg);
  i = (b<<8 & 0xFF00);
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
