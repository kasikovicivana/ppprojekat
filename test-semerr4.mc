//OPIS: pogresan tip kljuca pri dodjeli
//RETURN: 3

map <int,int> mapa4;

map <int,int> mapa1 = {{1,2}};

map <int,int> mapa2 = { {1,2},{2,5}};

map <int,int> mapa3 = { {4,2},{2,5}};

mapa4[4u] = 2;
mapa4[3] = 1;

int main() {
  int a;
  a = mapa1[1];
  mapa1[1] = 5;
  a = mapa4[4] + mapa4[3];
  return a;
}

