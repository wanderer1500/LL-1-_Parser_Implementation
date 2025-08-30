#include <bits/stdc++.h>
using namespace std;

map<string, vector<vector<string>>> grammar;
map<string, set<string>> FIRST, FOLLOW;
set<string> terminals, nonTerminals;
string startSymbol;

// Utility to split productions from { ... }
vector<string> split_rhs(const string &s) {
    vector<string> res;
    string cur;
    for (char c : s) {
        if (c == ',') {
            if (!cur.empty()) res.push_back(cur);
            cur.clear();
        } else if (c != '{' && c != '}') {
            cur.push_back(c);
        }
    }
    if (!cur.empty()) res.push_back(cur);
    return res;
}

// Parse grammar.txt
void loadGrammar(const string &filename) {
    ifstream in(filename);
    string line;
    bool firstLine = true;
    while (getline(in, line)) {
        if (line.empty()) continue;
        stringstream ss(line);
        string lhs, eq, rhs;
        ss >> lhs >> eq >> rhs;
        nonTerminals.insert(lhs);
        if (firstLine) { startSymbol = lhs; firstLine = false; }

        vector<string> productions = split_rhs(rhs);
        for (auto &prod : productions) {
            vector<string> symbols;
            string cur;
            for (char c : prod) {
                if (isupper(c)) { // non-terminal
                    if (!cur.empty()) {
                        terminals.insert(cur);
                        symbols.push_back(cur);
                        cur.clear();
                    }
                    string NT(1, c);
                    symbols.push_back(NT);
                    nonTerminals.insert(NT);
                } else {
                    cur.push_back(c);
                }
            }
            if (!cur.empty()) {
                terminals.insert(cur);
                symbols.push_back(cur);
            }
            grammar[lhs].push_back(symbols);
        }
    }
}

// FIRST computation
set<string> computeFIRST(const string &sym);

set<string> computeFIRST(const string &sym) {
    if (FIRST.count(sym)) return FIRST[sym];

    set<string> result;
    if (terminals.count(sym) && !nonTerminals.count(sym)) {
        result.insert(sym);
        return FIRST[sym] = result;
    }

    for (auto &prod : grammar[sym]) {
        bool epsilonAll = true;
        for (auto &X : prod) {
            set<string> firstX = computeFIRST(X);
            bool hasEps = false;
            for (auto &f : firstX) {
                if (f == "#") hasEps = true;
                else result.insert(f);
            }
            if (!hasEps) { epsilonAll = false; break; }
        }
        if (epsilonAll) result.insert("#");
    }
    return FIRST[sym] = result;
}

// FOLLOW computation
void computeFOLLOW() {
    FOLLOW[startSymbol].insert("$");
    bool changed = true;
    while (changed) {
        changed = false;
        for (auto &rule : grammar) {
            string A = rule.first;
            for (auto &prod : rule.second) {
                for (int i = 0; i < prod.size(); i++) {
                    string B = prod[i];
                    if (!nonTerminals.count(B)) continue;

                    bool epsilonTrail = true;
                    for (int j = i+1; j < prod.size(); j++) {
                        epsilonTrail = false;
                        for (auto &f : computeFIRST(prod[j])) {
                            if (f != "#") {
                                if (!FOLLOW[B].count(f)) {
                                    FOLLOW[B].insert(f);
                                    changed = true;
                                }
                            }
                        }
                        if (computeFIRST(prod[j]).count("#")) epsilonTrail = true;
                        else { epsilonTrail = false; break; }
                    }
                    if (epsilonTrail) {
                        for (auto &f : FOLLOW[A]) {
                            if (!FOLLOW[B].count(f)) {
                                FOLLOW[B].insert(f);
                                changed = true;
                            }
                        }
                    }
                }
            }
        }
    }
}
void writeSetsToFiles() {
    ofstream firstFile("first.txt");
    ofstream followFile("follow.txt");

    if (!firstFile || !followFile) {
        cerr << "Error opening output files.\n";
        return;
    }

    // FIRST sets
    for (auto &nt : nonTerminals) {
        firstFile << nt << " = {";
        bool first = true;
        for (auto &s : FIRST[nt]) {
            if (!first) firstFile << ",";
            firstFile << s;
            first = false;
        }
        firstFile << "}\n";
    }

    // FOLLOW sets
    for (auto &nt : nonTerminals) {
        followFile << nt << " = {";
        bool first = true;
        for (auto &s : FOLLOW[nt]) {
            if (!first) followFile << ",";
            followFile << s;
            first = false;
        }
        followFile << "}\n";
    }

    firstFile.close();
    followFile.close();
}
int main() {
    loadGrammar("grammar.txt");
    for (auto &nt : nonTerminals) computeFIRST(nt);
    computeFOLLOW();

    cout << "FIRST sets:\n";
for (auto &nt : nonTerminals) {
    cout << nt << " = {";
    bool first = true;
    for (auto &s : FIRST[nt]) {
        if (!first) cout << ",";
        cout << s;
        first = false;
    }
    cout << "}\n";
}

cout << "\nFOLLOW sets:\n";
for (auto &nt : nonTerminals) {
    cout << nt << " = {";
    bool first = true;
    for (auto &s : FOLLOW[nt]) {
        if (!first) cout << ",";
        cout << s;
        first = false;
    }
    cout << "}\n";
}
writeSetsToFiles();
}
