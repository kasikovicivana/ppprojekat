%{
  #include <stdio.h>
  #include <string.h>
  #include <stdlib.h>
  #include "defs.h"
  #include "symtab.h"
  #include "codegen.h"

  int yyparse(void);
  int yylex(void);
  int yyerror(char *s);
  void warning(char *s);
	void first_parse();

  extern int yylineno;
  int out_lin = 0;
  char char_buffer[CHAR_BUFFER_LENGTH];
  int error_count = 0;
  int warning_count = 0;
  int var_num = 0;
  int fun_idx = -1;
  int fcall_idx = -1;
  int lab_num = -1;
  FILE *output;
  struct_dict_elements* elements_map[128];
  int idx = 0;
  int array_assigned_elements_idx[100];
  int num_assigned_elements = 0;
	int elements_num = 0;
  

%}

%union {
  int i;
  char *s;
}

%token <i> _TYPE
%token _IF
%token _ELSE
%token _RETURN
%token <s> _ID
%token <s> _INT_NUMBER
%token <s> _UINT_NUMBER
%token _LPAREN
%token _RPAREN
%token _LBRACKET
%token _RBRACKET
%token _ASSIGN
%token _SEMICOLON
%token <i> _AROP
%token <i> _RELOP
%token _MAP
%token _COMMA
%token _RCORNER
%token _LCORNER

%type <i> num_exp exp literal assign_dict
%type <i> function_call argument rel_exp if_part

%nonassoc ONLY_IF
%nonassoc _ELSE

%%

program
  : dictionary_list
		 {
			struct_dict_elements* elements = (struct_dict_elements*) malloc(sizeof(struct_dict_elements)*128);
           elements_map[0] = elements;
			} 

		assign_values_block function_list 
      {  
        if(lookup_symbol("main", FUN) == NO_INDEX){
          err("undefined reference to 'main'");}
      }

  ;

assign_values_block
	:
	| assign_value assign_values_block
	;

assign_value
	:assign_dict _ASSIGN num_exp _SEMICOLON
      {
					struct_dict_elements new_element;
					new_element.idx =$1;
					new_element.value =$3;
					elements_map[0][elements_num] = new_element;
					elements_num++;
        }
  ;
dictionary_list
	:
	|	dictionary dictionary_list
	;

dictionary
	:	_MAP _RELOP _TYPE _COMMA _TYPE _RELOP _ID 
		{
			
			if ($2 != 0)
			{
        err("invalid syntax in dictionary declaration");
			}
			if ($6 != 1)
			{
        err("invalid syntax in dictionary declaration");
			}
        if (lookup_symbol($7, MAP) != NO_INDEX)
           err("already defined dictionary with same name '%s'", $7);
        else{
			
      idx = insert_symbol($7, MAP, $5, $3, 0);
			}

		}values_def _SEMICOLON
	;

values_def
	:	
	| _ASSIGN _LBRACKET values_list _RBRACKET  
	;

values_list
	:	value
	| 	values_list _COMMA value 
	;

value
	:	_LBRACKET literal _COMMA literal _RBRACKET
		{
			char* map_attribute_name;
		  char* map_name = get_name(idx);
			map_attribute_name = malloc(strlen(map_name)+1+90);
			strcat(map_attribute_name, map_name);
			strcat(map_attribute_name, "_"); 
			strcat(map_attribute_name, get_name($2));
			int id = lookup_symbol(map_attribute_name, MAP_ATR);
			if (id != -1){
          		err("Key already used '%s'", get_name($2));
			}
			  code("\n%s:\n\t\tWORD\t1", map_attribute_name);
		int atr_id = insert_symbol(map_attribute_name, MAP_ATR,get_type(idx)
															,atoi(get_name($2)),atoi(get_name($4)));
			array_assigned_elements_idx[num_assigned_elements]= atr_id;
	    num_assigned_elements++;
		}
	;	


	
function_list
  : function
  | function_list function
  ;

function
  : _TYPE _ID
      {
        fun_idx = lookup_symbol($2, FUN);
        if(fun_idx == NO_INDEX)
          fun_idx = insert_symbol($2, FUN, $1, NO_ATR, NO_ATR);
        else 
          err("redefinition of function '%s'", $2);

        code("\n%s:", $2);
        code("\n\t\tPUSH\t%%14");
        code("\n\t\tMOV \t%%15,%%14");
      }
    _LPAREN parameter _RPAREN body
      {
        clear_symbols(fun_idx + 1);
        var_num = 0;
        
        code("\n@%s_exit:", $2);
        code("\n\t\tMOV \t%%14,%%15");
        code("\n\t\tPOP \t%%14");
        code("\n\t\tRET");
				}
  ;

parameter
  : /* empty */
      { 

				set_atr1(fun_idx, 0); }

  | _TYPE _ID
      {

        insert_symbol($2, PAR, $1, 1, NO_ATR);
				set_atr1(fun_idx, 1);
        set_atr2(fun_idx, $1);
				
      }
  ;

body
  : _LBRACKET variable_list
      {
        if(var_num)
          code("\n\t\tSUBS\t%%15,$%d,%%15", 4*var_num);
					const char* name = get_name(fun_idx);
        	code("\n@%s_body:", name);
        char* name_with_extension;
				name_with_extension = malloc(strlen(name)+1+50);
				strcpy(name_with_extension, get_name(fun_idx));
				strcat(name_with_extension, "_body"); 
	 			if (strcmp(name_with_extension, "main_body") == 0){
							
              int i = 0;
              for(; i < num_assigned_elements; i++){
              	int idx = array_assigned_elements_idx[i];
              	char* name_with_extension;
	    				name_with_extension = malloc(100);
	    				sprintf(name_with_extension, "%d", get_atr2(idx));
              	gen_mov(lookup_symbol(name_with_extension, LIT), idx);}
              }
							int v = 0;
              for(; v < elements_num; v++){
							struct_dict_elements elem = elements_map[0][v];
						if (get_type(elem.value)!=get_type(elem.idx)){
							err("uncompatible type of dictionary key '%d'", elem.idx);
						}
          	  if (get_atr1(elem.idx)==NO_ATR){  
				  			gen_mov(elem.value, elem.idx);
							}	else{
					  	if(get_type(elem.idx) != get_type(elem.value))
								err("incompatible types in assignmenttt"); 
							gen_mov(elem.value, elem.idx);
				    }
              	
        }
							}
            

      
    statement_list _RBRACKET
  ;

variable_list
  : /* empty */
  | variable_list variable
  ;

variable
  : _TYPE _ID _SEMICOLON
      {
			//if(first_time != -1){
        if(lookup_symbol($2, VAR|PAR) == NO_INDEX)
           insert_symbol($2, VAR, $1, ++var_num, NO_ATR);
        else 
           err("redefinition of '%s'", $2);
				}
      //}
  ;

statement_list
  : /* empty */
  | statement_list statement
  ;

statement
  : compound_statement
  | assignment_statement
  | if_statement
  | return_statement
  ;

compound_statement
  : _LBRACKET statement_list _RBRACKET
  ;

assignment_statement
  : _ID _ASSIGN num_exp _SEMICOLON
      {

        int idx = lookup_symbol($1, VAR|PAR);
        if(idx == NO_INDEX)
          err("invalid lvalue '%s' in assignment", $1);
        else
          if(get_type(idx) != get_type($3))
            err("incompatible types in assignmentt");
        gen_mov($3, idx);}

	| assign_dict _ASSIGN num_exp _SEMICOLON
      {

					if (get_atr1($1)==NO_ATR){ 
				  		gen_mov($3, $1);
					}	
          if ($1 != -1){
	      	if(get_type($1) != get_type($3))
			err("incompatible types in assignmenttt"); 
	    	gen_mov($3, $1);
        }}

  ;

num_exp
  : exp

  | num_exp _AROP exp
      {

        if(get_type($1) != get_type($3))
          err("invalid operands: arithmetic operation");
        int t1 = get_type($1);    
        code("\n\t\t%s\t", ar_instructions[$2 + (t1 - 1) * AROP_NUMBER]);
        gen_sym_name($1);
        code(",");
        gen_sym_name($3);
        code(",");
        free_if_reg($3);
        free_if_reg($1);
        $$ = take_reg();
        gen_sym_name($$);
        set_type($$, t1);
			}
  ;

exp
  : literal

  | _ID
      {

        $$ = lookup_symbol($1, VAR|PAR);
        if($$ == NO_INDEX)
          err("'%s' undeclared", $1);
				}

  | function_call
      {


        $$ = take_reg();
        gen_mov(FUN_REG, $$);}

  | _LPAREN num_exp _RPAREN
      { $$ = $2; }
 | assign_dict
      { $$ = $1; }
  ;

assign_dict
	: _ID _LCORNER literal _RCORNER
	{
	idx = lookup_symbol($1, MAP);
	if (idx == NO_INDEX){
		err("undefined map '%s'", $1);
		
	}
	else
	{
	if (get_atr1(idx)!=get_type($3)){
			err("uncompatible type of dictionary key '%d'", $3);
	}
	char* map_attribute_name;
	const char* name = $1;
	map_attribute_name = malloc(strlen(name)+1+50);
	strcpy(map_attribute_name, name); 
	strcat(map_attribute_name, "_"); 
	strcat(map_attribute_name, get_name($3));
	int id = lookup_symbol(map_attribute_name, MAP_ATR);
	if (id == -1){
		code("\n%s:\n\t\tWORD\t1", map_attribute_name);
		$$ = insert_symbol(map_attribute_name, MAP_ATR,get_type(idx),NO_ATR, atoi(get_name($3)));
	}else{
		$$ = id;
	}
	}}
	;
 
literal
  : _INT_NUMBER
      { $$ = insert_literal($1, INT); }

  | _UINT_NUMBER
      { $$ = insert_literal($1, UINT); }
  ;

function_call
  : _ID 
      {
        fcall_idx = lookup_symbol($1, FUN);
        if(fcall_idx == NO_INDEX)
          err("'%s' is not a function", $1);
      }
    _LPAREN argument _RPAREN
      {
        if(get_atr1(fcall_idx) != $4)
          err("wrong number of arguments");
        code("\n\t\t\tCALL\t%s", get_name(fcall_idx));
        if($4 > 0)
          code("\n\t\t\tADDS\t%%15,$%d,%%15", $4 * 4);
        set_type(FUN_REG, get_type(fcall_idx));
        $$ = FUN_REG;}
     
  ;

argument
  : /* empty */
    { $$ = 0; }

  | num_exp
    { 
				//if(first_time != -1){
      if(get_atr2(fcall_idx) != get_type($1))
        err("incompatible type for argument");
      free_if_reg($1);
      code("\n\t\t\tPUSH\t");
      gen_sym_name($1);
      $$ = 1;}
    //}
  ;

if_statement
  : if_part %prec ONLY_IF
      {
			//if(first_time != -1){
			 code("\n@exit%d:", $1); }//}

  | if_part _ELSE statement
      { 
					//if(first_time != -1){
			code("\n@exit%d:", $1); }//}
  ;

if_part
  : _IF _LPAREN
      {
			//if(first_time == -1){
        $<i>$ = ++lab_num;
        code("\n@if%d:", lab_num);}
     // }
    rel_exp
      {
				//if(first_time == -1){
        code("\n\t\t%s\t@false%d", opp_jumps[$4], $<i>3);
        code("\n@true%d:", $<i>3);}
      //}
    _RPAREN statement
      {
			//if(first_time == -1){
        code("\n\t\tJMP \t@exit%d", $<i>3);
        code("\n@false%d:", $<i>3);
        $$ = $<i>3;}
     // }
  ;

rel_exp
  : num_exp _RELOP num_exp
      {
			//if(first_time == -1){
        if(get_type($1) != get_type($3))
          err("invalid operands: relational operator");
        $$ = $2 + ((get_type($1) - 1) * RELOP_NUMBER);
        gen_cmp($1, $3);}
      //}
  ;

return_statement
  : _RETURN num_exp _SEMICOLON
      {
					//	if(first_time == -1){
        if(get_type(fun_idx) != get_type($2))
          err("incompatible types in return");
        gen_mov($2, FUN_REG);
        code("\n\t\tJMP \t@%s_exit", get_name(fun_idx));        
      }//}
  ;

%%


int yyerror(char *s) {
  fprintf(stderr, "\nline %d: ERROR: %s", yylineno, s);
  error_count++;
  return 0;
}

void warning(char *s) {
  fprintf(stderr, "\nline %d: WARNING: %s", yylineno, s);
  warning_count++;
}

int main() {
  int synerr;
  init_symtab();
  output = fopen("output.asm", "w+");

  synerr = yyparse();
  clear_symtab();
  fclose(output);
  
  if(warning_count)
    printf("\n%d warning(s).\n", warning_count);

  if(error_count) {
    remove("output.asm");
    printf("\n%d error(s).\n", error_count);
  }
    printf("\n prosaoooo.\n");
  if(synerr)
    return -1;  //syntax error
  else if(error_count)
    return error_count & 127; //semantic errors
  else if(warning_count)
    return (warning_count & 127) + 127; //warnings
  else
    return 0; //OK
}

