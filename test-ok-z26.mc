//OPIS: pristup globalnoj mapi i redefinisanje vrijednosti
//RETURN: 7

map <int,int> mapa1 = {{1,2}};

map <int,int> mapa2 = { {1,2},{3,5}};

map <int,int> mapa3 = { {4,2},{2,5}};

int main() {
  int a;
  a = mapa1[1];
	mapa1[1]=7;
  return mapa1[1];
}


