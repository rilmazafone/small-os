void memory_copy(char *source, char *dest, int nbytes){
    for(int i=0;i<nbytes;i++){
        *(dest+i) = *(source + i);
    }
}

void int_to_ascii(int n, char str[]){
    int sign = n;
    int i = 0;

    if (sign < 0){
        n = -n;
    }

    do {
        str[i++] = n % 10 + '0';
    } while ((n /= 10) > 0);

    if (sign < 0) str[i++] = '-';
    str[i] = '\0';
}