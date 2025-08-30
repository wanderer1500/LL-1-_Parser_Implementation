%{

#include <bits/stdc++.h>
using namespace std;


#define MP make_pair
#define F first
#define S second

string startSymbol = "E";

map<string,vector<string>> first;
map<string,vector<string>> follow;
map<string,vector<string>> production;
map<string, map<string, string>> parse_table;
set<string> terminal={"i","*","+","(",")"};
set<string> non_terminal;

string cur_key;
vector<string> cur_vals;
enum Mode{
	first_mode,
	follow_mode,
	grammar_mode
};
Mode cur_mode;

void print_map(const map<string, vector<string>>& mp, const string& title) {
    cout << title << ":\n";
    for (auto &p : mp) {
        cout << p.first << " -> ";
        for (auto &val : p.second) cout << val << " ";
        cout << "\n";
    }
    cout << "\n";
}

string charTostr(char c){
	string s = "";
	s.push_back(c);
	return s;
}

%}
id [a-zA-Z$#()+*]+
ws [ \t\n]+

%%
{ws} {}
{id} {
	if(cur_key.empty()){
	
		cur_key = yytext; // lhs
		
	}else { // rhs
		cur_vals.push_back(yytext);
	}
 }
"=" {}
"{" {}
"," {}
"}" {
	if(!cur_key.empty()){
		if(cur_mode == first_mode){
			 first[cur_key] = cur_vals; 
		}else if(cur_mode == follow_mode){
			follow[cur_key] = cur_vals;
		}else{
			production[cur_key] = cur_vals;
		}
		cur_key.clear();
		cur_vals.clear();
	}
}
. {}
%%

void parse_first(){
	yyin = fopen("first.txt","r");
	cur_mode = first_mode;
	yylex();
	fclose(yyin);
}
void parse_follow(){
	yyin = fopen("follow.txt","r");
	cur_mode = follow_mode;
	yylex();
	fclose(yyin);
}
void parse_grammar(){
	yyin = fopen("grammar.txt","r");
	cur_mode = grammar_mode;
	yylex();
	fclose(yyin);
}

void build_parse_table() {
    // collect non-terminals
    for (auto &f : first) {
        non_terminal.insert(f.F);
    }

    // loop over productions
    for (auto &prod : production) {
        string A = prod.F;              // non-terminal
        vector<string> rhsList = prod.S; // list of productions for A

        for (auto &rhs : rhsList) { // each production (like "(S)", "aSb", "d")
            string firstSym = rhs.substr(0, 1); // take first symbol properly

            bool isEpsilon = (rhs == "#");
            bool isTerminal = terminal.count(firstSym);
            bool isNT = non_terminal.count(firstSym);

            if (isEpsilon) {
                for (auto &f : follow[A]) {
                    parse_table[A][f] = A + "->" + rhs;
                }
            } 
            else if (isTerminal) {
                parse_table[A][firstSym] = A + "->" + rhs;
            } 
            else if (isNT) {
                for (auto &f : first[firstSym]) {
                    if (f == "#") {
                        for (auto &ff : follow[A]) {
                            parse_table[A][ff] = A + "->" + rhs;
                        }
                    } else {
                        parse_table[A][f] = A + "->" + rhs;
                    }
                }
            }
        }
    }
}




void print_parse_table() {
    cout << "LL(1) Parse Table:\n\t";

    // print header row (all terminals + $)
    for (auto &t : terminal) cout << t << "\t";
    cout << "$\n";

    // print each row (for each non-terminal)
    for (auto &nt : non_terminal) {
        cout << nt << "\t";
        for (auto &t : terminal) {
            if (parse_table[nt].count(t)) {
                cout << parse_table[nt][t] << "\t";
            } else {
                cout << "error\t";
            }
        }
        // also check for $
        if (parse_table[nt].count("$")) {
            cout << parse_table[nt]["$"] << "\t";
        } else {
            cout << "error\t";
        }
        cout << "\n";
    }
}

bool parse_input(string& input, const string& start) {
    stack<string> stk;
    stk.push("$");          // end marker
    stk.push(start);        // start symbol
    int ip = 0;
    while(stk.top()!="$" && ip<input.size()){
		string X = stk.top();stk.pop();
		string a(1, input[ip]);
		if(terminal.count(X)){
			if(X==a){
				cout << "match " << a << endl;
				
				ip++;
			}else {
				cout << "Error: expected " << X << " but found " << a << endl;
                return false;
			}
			
		}else if(non_terminal.count(X)){
			if(parse_table[X][a] == "error"){
				cout << "Error: no rule for M[" << X << "," << a << "]" << endl;
                return false;
			}else{
				string prod = parse_table[X][a];
				cout<<prod<<endl;
				if(prod == "#") continue;
				string rhs = prod.substr(prod.find("->")+2);
				
				for(int i=rhs.size()-1;i>=0;i--){
					stk.push(rhs.substr(i,1));
				}
				
			}
		}
	}
	return true;
}




int yywrap(){
    return 1;
}
int main(){
	parse_first();
    parse_follow();
	parse_grammar();
    print_map(first, "FIRST sets");
    print_map(follow, "FOLLOW sets");
    print_map(production, "PRODUCTION rules");
    build_parse_table();
    print_parse_table();
    
     // Read input from file
    ifstream fin("input.txt");
    string input;
    fin >> input;
    fin.close();
   

    cout << "\nParsing input: " << input << endl;
    if (parse_input(input, startSymbol)) {
        cout << "Input string is VALID.\n";
    } else {
        cout << "Input string is NOT valid.\n";
    }

    return 0;
}


