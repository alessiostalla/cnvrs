import org.antlr.v4.runtime.misc.MurmurHash;
/** Unsigned bit-pattern boundary fixtures for the typed/inlined Lisp helpers. */
public final class MurmurOracle {
 public static void main(String[] args) {
  int[] values={0,1,2,0x7fffffff,0x80000000,0xfffffffe,0xffffffff};
  int[] words={0,1,2,0x3fffffff,0x40000000,0x7fffffff,0x80000000,0xffffffff};
  for(int hash:values){
   for(int value:values)System.out.println("(:update "+Integer.toUnsignedLong(hash)+" "+Integer.toUnsignedLong(value)+" "+Integer.toUnsignedLong(MurmurHash.update(hash,value))+")");
   for(int count:words)System.out.println("(:finish "+Integer.toUnsignedLong(hash)+" "+Integer.toUnsignedLong(count)+" "+Integer.toUnsignedLong(MurmurHash.finish(hash,count))+")");
   for(int bits:new int[]{0,1,13,15,31})System.out.println("(:rotate "+Integer.toUnsignedLong(hash)+" "+bits+" "+Integer.toUnsignedLong(Integer.rotateLeft(hash,bits))+")");
  }
 }
}
