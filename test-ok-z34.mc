//OPIS: testiranje aritmetickih operacija
//RETURN: 3

map <int,int> mapa4;

map <int,int> mapa1 = {{1,2}};

map <int,unsigned> mapa2 = { {1,2u},{2,5u}};

map <int,int> mapa3 = { {4,2},{2,5}};

mapa4[4] = 2;
mapa3[4] = 1;

int main() {
  int a;
  a = mapa1[1];
  mapa2[1] = 4u;
  a = mapa3[4] + mapa4[4];
  return a;
}


