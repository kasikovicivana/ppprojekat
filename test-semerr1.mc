//OPIS: definisanje rjecnika sa vec postojecim imenom
//RETURN: 3

map <int,int> mapa4;

map <int,int> mapa4 = {{1,2}};

map <int,int> mapa2 = { {1,2},{2,5}};

map <int,int> mapa3 = { {4,2},{2,5}};

mapa4[4] = 2;
mapa4[3] = 1;

int main() {
  int a;
  a = mapa4[4] + mapa4[3];
  return a;
}


