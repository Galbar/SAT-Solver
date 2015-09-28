#include <iostream>
#include <stdlib.h>
#include <algorithm>
#include <vector>
#include <time.h>
using namespace std;

#define UNDEF -1
#define TRUE 1
#define FALSE 0

uint numVars;
uint numClauses;
vector<vector<int> > clauses;
vector<int> model;
vector<int> modelStack;
uint indexOfNextLitToPropagate;
uint decisionLevel;


int decisions;
int propagations;
vector<vector<int> > positiveLitClauses;
vector<vector<int> > negativeLitClauses;
vector<int> scores;


vector<int>& getLitClauses(int lit)
{
    if (lit > 0)
        return negativeLitClauses[lit];
    return positiveLitClauses[-lit];
}


void readClauses( )
{
    // Skip comments
    char c = cin.get();
    while (c == 'c')
    {
        while (c != '\n') c = cin.get();
        c = cin.get();
    }
    // Read "cnf numVars numClauses"
    string aux;
    cin >> aux >> numVars >> numClauses;
    clauses.resize(numClauses);
    positiveLitClauses.resize(numVars+1);
    negativeLitClauses.resize(numVars+1);
    scores.resize(numVars+1,0);
    // Read clauses
    for (uint i = 0; i < numClauses; ++i)
    {
        int lit;
        while (cin >> lit and lit != 0)
        {
            clauses[i].push_back(lit);
            if (lit > 0)
            {
                positiveLitClauses[lit].push_back(i);
                ++scores[lit];
            }
            else

            {
                negativeLitClauses[-lit].push_back(i);
                ++scores[-lit];
            }
        }
    }
}


int currentValueInModel(int lit)
{
    if (lit >= 0) return model[lit];
    else
    {
        if (model[-lit] == UNDEF) return UNDEF;
        else return 1 - model[-lit];
    }
}


void setLiteralToTrue(int lit)
{
    modelStack.push_back(lit);
    if (lit > 0)
        model[lit] = TRUE;
    else
        model[-lit] = FALSE;
}


void reduceConflicts()
{
    for (uint i = 1; i < scores.size(); ++i)
        scores[i] = scores[i]/2;
}


bool propagateGivesConflict()
{
    while ( indexOfNextLitToPropagate < modelStack.size())
    {
        int lit = modelStack[indexOfNextLitToPropagate];
        vector<int>& litClauses = getLitClauses(lit);
        lit = abs(lit);
        for (uint i = 0; i < litClauses.size(); ++i)
        {
            bool someLitTrue = false;
            int numUndefs = 0;
            int lastLitUndef = 0;
            for (uint k = 0; not someLitTrue and k < clauses[litClauses[i]].size(); ++k)
            {
                int val = currentValueInModel(clauses[litClauses[i]][k]);
                if (val == TRUE)
                    someLitTrue = true;
                else if (val == UNDEF)
                {
                    ++numUndefs;
                    lastLitUndef = clauses[litClauses[i]][k];
                }
            }
            if (not someLitTrue and numUndefs == 0)
            {
                for (uint k = 0; k < clauses[litClauses[i]].size(); ++k)
                    scores[abs(clauses[litClauses[i]][k])] += 3;
                return true; // conflict! all lits false
            }
            else if (not someLitTrue and numUndefs == 1)
            {
                setLiteralToTrue(lastLitUndef);
                ++propagations;
            }
        }
        ++indexOfNextLitToPropagate;
    }
    return false;
}


void backtrack()
{
    uint i = modelStack.size() -1;
    int lit = 0;
    while (modelStack[i] != 0)   // 0 is the DL mark
    {
        lit = modelStack[i];
        model[abs(lit)] = UNDEF;
        modelStack.pop_back();
        --i;
    }
    modelStack.pop_back(); // remove the DL mark
    --decisionLevel;
    indexOfNextLitToPropagate = modelStack.size();
    setLiteralToTrue(-lit);  // reverse last decision
}


int getNextDecisionLiteral()
{
    int ret = 0;
    int cPSize = scores.size();
    int maximo = -1;
    for (uint i = 1; i < cPSize; ++i)
    {
        if (model[i] == UNDEF)
        {
            if (scores[i] > maximo)
            {
                maximo = scores[i];
                ret = i;
            }
        }
    }
    if (decisions % 1255 == 0)
        reduceConflicts();
    return ret;
}


void checkmodel()
{
    for (int i = 0; i < numClauses; ++i)
    {
        bool someTrue = false;
        for (int j = 0; not someTrue and j < clauses[i].size(); ++j)
            someTrue = (currentValueInModel(clauses[i][j]) == TRUE);
        if (not someTrue)
        {
            cout << "Error in model, clause is not satisfied:";
            for (int j = 0; j < clauses[i].size(); ++j) cout << clauses[i][j] << " ";
                cout << endl;
            exit(1);
        }
    }
}


void print(clock_t t)
{
    double c = (double)(clock()-t)/CLOCKS_PER_SEC;
    cout << "c " << c << " seconds total run time" << endl;
    cout << "c " << decisions << " decisions" << endl;
    cout << "c " << (double)propagations/(c*1000000) << " megaprops/second" << endl;
}


int main(){
    clock_t t = clock();
    readClauses(); // reads numVars, numClauses and clauses
    model.resize(numVars+1,UNDEF);
    indexOfNextLitToPropagate = 0;
    decisionLevel = 0;
    decisions = 0;
    propagations = 0;

  // Take care of initial unit clauses, if any
    for (uint i = 0; i < numClauses; ++i)
        if (clauses[i].size() == 1)
        {
            int lit = clauses[i][0];
            int val = currentValueInModel(lit);
            if (val == FALSE)
            {
                cout << "s UNSATISFIABLE" << endl;
                print(t);
                return 10;
            }
            else if (val == UNDEF) setLiteralToTrue(lit);
        }

    // DPLL algorithm
    while (true)
    {
        while ( propagateGivesConflict() )
        {
            if (decisionLevel == 0)
            {
                cout << "s UNSATISFIABLE" << endl;
                print(t);
                return 10;
            }
            backtrack();
        }
        int decisionLit = getNextDecisionLiteral();
        if (decisionLit == 0)

        {
            checkmodel();
            cout << "s SATISFIABLE" << endl;
            print(t);
            return 20;
        }
        // start new decision level:
        modelStack.push_back(0);  // push mark indicating new DL
        ++indexOfNextLitToPropagate;
        ++decisionLevel;
        ++decisions;
        setLiteralToTrue(decisionLit);    // now push decisionLit on top of the mark
    }
}
