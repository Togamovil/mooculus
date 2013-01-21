
/* description: Parses end executes mathematical expressions. */

/* lexical grammar */
%lex
%%

\s+                   /* skip whitespace */
//[0-9]+("."[0-9]+)?\b  return 'NUMBER'
[0-9]+("."[0-9]+)?      return 'NUMBER'
"e"                     return 'E'
[A-Za-z]\b              return 'VAR'
"*"                     return '*'
"/"                     return '/'
"-"                     return '-'
"+"                     return '+'
"^"                     return '^'
"("                     return '('
")"                     return ')'
"pi"                    return 'PI'
"sin"                   return 'SIN'
"cos"                   return 'COS'
"tan"                   return 'TAN'
"csc"                   return 'CSC'
"sec"                   return 'SEC'
"cot"                   return 'COT'
"arcsin"                return 'ARCSIN'
"arccos"                return 'ARCCOS'
"arctan"                return 'ARCTAN'
"log"                   return 'LOG'
"ln"                    return 'LOG'
"exp"                   return 'EXP'
"sqrt"                  return 'SQRT'
<<EOF>>                 return 'EOF'
.                       return 'INVALID'

/lex

/* operator associations and precedence */


%left '+' '-'
%left '*' '/'
%left '^'
%left FUNCTION_APPLICATION
%left UMINUS

%start expressions

%% /* language grammar */

expressions
    : e EOF
        { typeof console !== 'undefined' ? console.log($1) : print($1);
          return $1; }
    ;

number
    : NUMBER
        {$$ = new StraightLineProgram(function(bindings){ return parseFloat(yytext); },
				      parseFloat(yytext).toString(),
				      parseFloat(yytext).toString());}
    ;

variable
    : VAR
        {$$ = new StraightLineProgram(function(bindings){ return bindings[yytext.toLowerCase()]; },
				      yytext.toLowerCase(),
				      yytext.toLowerCase());}
    ;

e
    : e '+' e
        {$$ = new StraightLineProgram(function(bindings){ return $1.f(bindings) + $3.f(bindings); },
				      '\\left(' + $1.tex + ' + ' + $3.tex + '\\right)',
				      ['+', $1.syntax_tree, $3.syntax_tree] );}
    | e '-' e
        {$$ = new StraightLineProgram(function(bindings){ return $1.f(bindings) - $3.f(bindings); },
				      '\\left(' + $1.tex + ' - ' + $3.tex + '\\right)',
				      ['-', $1.syntax_tree, $3.syntax_tree] );}
    | e '*' e
        {$$ = new StraightLineProgram(function(bindings){ return $1.f(bindings) * $3.f(bindings); },
				      '\\left(' + $1.tex + ' \\cdot ' + $3.tex + '\\right)',
				      ['*', $1.syntax_tree, $3.syntax_tree] );}
    | number variable '^' e
        {$$ = new StraightLineProgram(function(bindings){ return Math.pow($1.f(bindings) * $2.f(bindings),$4.f(bindings)); },
	  			      '\\left(' + $1.tex + ' \\cdot \\left(' + $2.tex + '\\right)^{' + $4.tex + '}\\right)',
				      ['*', $1.syntax_tree, ['^', $2.syntax_tree, $4.syntax_tree]] );}
    | variable
        {$$ = $1}
    | number variable %prec '*'
        {$$ = new StraightLineProgram(function(bindings){ return $1.f(bindings) * $2.f(bindings); },
				      '\\left(' + $1.tex + ' \\cdot ' + $2.tex + '\\right)',
				      ['*', $1.syntax_tree, $2.syntax_tree] );}
    | e '/' e
        {$$ = new StraightLineProgram(function(bindings){ return $1.f(bindings) / $3.f(bindings); },
				      '\\displaystyle\\frac{' + $1.tex + '}{' + $3.tex + '}',
				      ['/', $1.syntax_tree, $3.syntax_tree] );}
    | e '^' e
        {$$ = new StraightLineProgram(function(bindings){ return Math.pow($1.f(bindings),$3.f(bindings)); },
				      '\\left(' + $1.tex + '\\right)^{' + $3.tex + '}',
				      ['^', $1.syntax_tree, $3.syntax_tree] );}
    | '-' e %prec UMINUS
        {$$ = new StraightLineProgram(function(bindings){ return -($2.f(bindings)); },
				      '-\\left(' + $2.tex + '\\right)',
				      ['*', -1, $2.syntax_tree] );}
    | '+' e %prec UMINUS
        {$$ = $2;}
    | '(' e ')'
        {$$ = $2;}
    | EXP e %prec FUNCTION_APPLICATION
        {$$ = new StraightLineProgram(function(bindings){ return Math.exp($2.f(bindings)); },
				      'e^{' + $2.tex + '}',
				      ['^', 'e', $2.syntax_tree] );}
    | LOG e %prec FUNCTION_APPLICATION
        {$$ = new StraightLineProgram(function(bindings){ return Math.log($2.f(bindings)); },
				      '\\log \\left(' + $2.tex + '\\right)',
				      ['log', $2.syntax_tree] );}
    | SIN e %prec FUNCTION_APPLICATION
        {$$ = new StraightLineProgram(function(bindings){ return Math.sin($2.f(bindings)); },
				      '\\sin \\left(' + $2.tex + '\\right)',
				      ['sin', $2.syntax_tree] );}
    | COS e %prec FUNCTION_APPLICATION
        {$$ = new StraightLineProgram(function(bindings){ return Math.cos($2.f(bindings)); },
				      '\\cos \\left(' + $2.tex + '\\right)',
				      ['cos', $2.syntax_tree] );}
    | TAN e %prec FUNCTION_APPLICATION
        {$$ = new StraightLineProgram(function(bindings){ return Math.tan($2.f(bindings)); },
				      '\\tan \\left(' + $2.tex + '\\right)',
				      ['tan', $2.syntax_tree] );}

    | CSC e %prec FUNCTION_APPLICATION
        {$$ = new StraightLineProgram(function(bindings){ return 1.0/Math.sin($2.f(bindings)); },
				      '\\csc \\left(' + $2.tex + '\\right)',
				      ['csc', $2.syntax_tree] );}
    | SEC e %prec FUNCTION_APPLICATION
        {$$ = new StraightLineProgram(function(bindings){ return 1.0/Math.cos($2.f(bindings)); },
				      '\\sec \\left(' + $2.tex + '\\right)',
				      ['sec', $2.syntax_tree] );}
    | COT e %prec FUNCTION_APPLICATION
        {$$ = new StraightLineProgram(function(bindings){ return 1.0/Math.tan($2.f(bindings)); },
				      '\\cot \\left(' + $2.tex + '\\right)',
				      ['cot', $2.syntax_tree] );}

    | ARCSIN e %prec FUNCTION_APPLICATION
        {$$ = new StraightLineProgram(function(bindings){ return Math.arcsin($2.f(bindings)); },
				      '\\arcsin \\left(' + $2.tex + '\\right)',
				      ['arcsin', $2.syntax_tree] );}
    | ARCCOS e %prec FUNCTION_APPLICATION
        {$$ = new StraightLineProgram(function(bindings){ return Math.arccos($2.f(bindings)); },
				      '\\arccos \\left(' + $2.tex + '\\right)',
				      ['arccos', $2.syntax_tree] );}
    | ARCTAN e %prec FUNCTION_APPLICATION
        {$$ = new StraightLineProgram(function(bindings){ return Math.arctan($2.f(bindings)); },
				      '\\arctan \\left(' + $2.tex + '\\right)',
				      ['arctan', $2.syntax_tree] );}
    | SQRT e %prec FUNCTION_APPLICATION
        {$$ = new StraightLineProgram(function(bindings){ return Math.pow($2.f(bindings),0.5); },
				      '\\sqrt{' + $2.tex + '}',
				      ['sqrt', $2.syntax_tree] );}
    | E
        {$$ = new StraightLineProgram(function(bindings){ return Math.E; },
				      'e', "e");}
    | PI
        {$$ = new StraightLineProgram(function(bindings){ return Math.PI; },
				      '\\pi', "pi");}
    | number
        {$$ = $1;}
    ;

%%

function StraightLineProgram(f,tex,tree)
{
    this.evaluate = f;
    this.tex = tex;
    this.syntax_tree = tree;
}

var sub = function(str) {
  return str.replace(/#\{(.*?)\}/g,
    function(whole, expr) {
      return eval(expr)
    })
}

var randomBindings = function() {
    var alphabet = "abcdefghijklmnopqrstuvwxyz";
    var result = new Object();
    for(var i=0; i<alphabet.length; i++) {
	result[alphabet.charAt(i)] = Math.random() * 20.0 - 10.0;
    }
    return result;
}

StraightLineProgram.prototype = {
    f: function(bindings) {
	this.evaluate(bindings)
    },

    equals: function(other) {
	var total_trials = 20;
	var epsilon = 0.0001;
	var successful_trials = 0;

        for( var i=0; i < total_trials; i++ ) {
	    bindings = randomBindings();
	    if (Math.abs(this.evaluate(bindings) - other.evaluate(bindings)) < epsilon) {
		successful_trials++;
	    }
	}
	return (successful_trials > 0.95 * total_trials);
    },

    equalsForBinding: function(other,bindings) {
	var epsilon = 0.0001;

	return (Math.abs(this.evaluate(bindings) - other.evaluate(bindings)) < epsilon);
    }
}