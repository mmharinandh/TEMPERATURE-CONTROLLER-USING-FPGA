unsigned int ReadTemperature()
{
	volatile u32 temperature = 0;
	unsigned char i = 0;
	volatile spi_t* max6675TC = (volatile spi_t*) (SPI_BASE_ADDRESS);

	for (i=0;i<15;i++)
	{
	   max6675TC->Cs = 0;
	   max6675TC->Clk = 1;
	   max6675TC->Clk = 0;
	   temperature = max6675TC->Data + (temperature<<1);

	 }
	 
	 temperature = temperature / 32;
	 max6675TC->Cs = 1;
	 return (temperature);

}


void LoadRunPWM(unsigned int period, unsigned int ontime)
{
	volatile pwm_t* pwm=(volatile pwm_t*) (PWM_BASE_ADDRESS);
	pwm->En = 0;
	pwm->Tp = period;
	pwm->Ton = ontime;
	pwm->En = 1;
}

void StopPWM()
{
	volatile pwm_t* pwm=(volatile pwm_t*) (PWM_BASE_ADDRESS);
	pwm->En = 0;
}

int main()
{
	unsigned int sec = 0;
	print("Start\n\r");
    //init_platform();

	//#define Kp 0.01;
	//#define Ki 0.05;
	//#define Kd 0.03;
	
	float Kp = 90, Ki = 30, Kd = 80;
	
	float temperature_read = 0;
	float pid_p = 0, pid_i = 0, pid_d = 0;
	
	float pid_error = 0;
	float prev_error = 0;	
	float pid_value = 0;
	
	float time, elapsed_time, prev_time;
	
	float set_temperature = 20;

	volatile u32 temperature = 0;
	print("Executing PID...\n\r");




    while(1)
    {
		temperature  = ReadTemperature();
		temperature_read = float(temperature);
		
		pid_error = set_temperature - temperature_read;
			
		prev_time = time;
		time = millis();
		elapsed_time = (time - prev_time)/1000;
		
		pid_p = 0.01*Kp*pid_error;
		pid_i = 0.01*pid_i + (ki*pid_error);
		
		pid_d = 0.01*Kd*((pid_error - prev_error)/elapsed_time);
		
		pid_value = pid_p + pid_i + pid_d;
		
		prev_error = pid_error;
		
		
	}
    return 0;
}

