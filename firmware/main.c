int main(void)
{
    volatile unsigned int *signature = (volatile unsigned int *) 0x100;
    int sum = 0;
    for (int i =0 ; i<10 ; i++){
        sum += i;
    }
    if (sum == 45)
        *signature = 0x600dcafe;
    else
        *signature = 0xdead0001;

    while (1);
}