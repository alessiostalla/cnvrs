/*
Func call with various arg numbers.
And func forward declarations.
And func call as func call argument.
*/

void aX(void);
int a1(int param1);
int a2(int param1, param2);
void a3();
void a3(void);

int f(int arg1, char arg2)
{
	a1(arg1);
	a2(arg1, arg2);
	a3();
	a1(a1());
	a1(a1(), a2(a1(), x1));
}

/*
Func call with various arg numbers.
And func forward declarations.
And func call as func call argument.
*/

void aX(void);
int a1(int param1);
int a2(int param1, param2);
void a3();
void a3(void);
void a4(int, ...);
void a4(int param1, ...);


int f(int arg1, char arg2)
{
	a1(arg1);
	a2(arg1, arg2);
	a3();
	a1(a1());
	a1(a1(), a2(a1(), x1));
}

//function pointer
typedef
void *
(*f1)(
          const MyType        *param1,
          long             param2,
    void              *param3,
          short             param4
  );


typedef
int
(*f2)(
          const MyType        *param1,
          long             param2,
    char              *param3,
          int             param4
  );


typedef
MyStruct
( *f3 ) (
          const MyType        *param1,
          double             param2,
    float              *param3,
          long             param4
  );
