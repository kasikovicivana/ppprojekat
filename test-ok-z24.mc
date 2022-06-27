//OPIS: pristup rjecniku
//RETURN: 2

map <int,int> mapa1= {{1,1}};

map <int,unsigned> mapa2 = { {1,2},{3,5}};

int main() {
  int a;
  mapa1[1] = 2;
  a = mapa1[1];
  return a;
}


