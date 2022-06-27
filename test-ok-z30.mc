//OPIS: testiranje aritmetickih operacija
//RETURN: 2

map <int,int> mapa4;

map <int,int> mapa1 = {{1,2}};

map <int,int> mapa2 = { {1,2},{2,5}};

map <int,int> mapa3 = { {4,2},{2,5}};

mapa4[4] = 2;

int main() {
  int a;
  a = mapa1[1];
  mapa1[1] = 5;
  a = mapa1[1] - mapa2[1];
  return mapa4[4];
}


