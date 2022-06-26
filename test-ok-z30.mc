//OPIS: testiranje aritmetickih operacija
//RETURN: 0

map <int,int> mapa4;

map <int,int> mapa1 = {{1,2}};

map <int,int> mapa2 = { {1,2},{3,5}};

map <int,int> mapa3 = { {4,2},{2,5}};

int main() {
  int a;
  mapa4[4] = 3;
  a = mapa1[1];
  mapa1[1] = 5;
  a = mapa1[1] - mapa2[1] - mapa4[4];
  return a;
}


