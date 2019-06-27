clear
export PATH=/home/kavan/Applications/kotlin-native-linux-1.3/bin:$PATH
export PATH=/home/kavan/Applications/kotlin-native-linux-1.3/jdk-12/bin:$PATH


SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TMPPATH="$SCRIPTPATH/.tmp"




SRCPATH="$SCRIPTPATH/src"
CINTROP="$SCRIPTPATH/cinterop"
BUILDPATH="$SCRIPTPATH/build"


# List of libraries in cintrop
for LIBPATH in "$CINTROP"/*; do if [ -d "$LIBPATH" ]; then 

    LIBNAME=$(basename "$LIBPATH")

    LIBS+=' -l '"$TMPPATH/$LIBNAME/$LIBNAME.klib"''
    LINKEROPS+=' -linker-options '"$TMPPATH/$LIBNAME/$LIBNAME.a"''


    # Create output directory for library
    if [ ! -d "$TMPPATH/$LIBNAME" ]; then mkdir -p "$TMPPATH/$LIBNAME"; fi


    # Generating intermediate object file
    gcc -c "-I$(pwd)" "$LIBPATH/$LIBNAME.c" -o "$TMPPATH/$LIBNAME/$LIBNAME.o"

    # Compiling static library
    ar rcs "$TMPPATH/$LIBNAME/$LIBNAME.a" "$TMPPATH/$LIBNAME/$LIBNAME.o"


    # C interop, generate kotlin library
    cinterop -def "$LIBPATH/$LIBNAME.def" -compilerOpts "-I$(pwd)" -o "$TMPPATH/$LIBNAME/$LIBNAME.klib"


 fi; done




#https://jonnyzzz.com/blog/2018/05/28/minimalistic-kn/
konanc $LIBS$LINKEROPS "$SRCPATH/main.kt" -o "$BUILDPATH/main.kexe" -opt


"$BUILDPATH/main.kexe"
