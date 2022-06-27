//OPIS: sabiranje vrijednosti rjecnika
//RETURN: 6

map <int,int> mapa1 = {{1,1}};

map <int,int> mapa2 = { {1,2},{3,5},{4,2}};

map <int,int> mapa3 = { {4,2},{2,5}};

int main() {
  int a;
  mapa1[1] = 3;
  a = mapa1[1] + mapa1[1];
  return a;
}


