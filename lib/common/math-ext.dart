
abs(value) => value > 0 ? value : -value;

//二分查找，没有找到 dart 的标准库的实现，就自己实现一个了
int binarySearch(List<int> array, int start,int end, int key){
  if(start > end) return -1;

  if(array[start] == key) return start;
  if(array[end] == key) return end;

  final middle = start + (end - start) ~/ 2;
  if(array[middle] == key) return middle;

  if(key < array[middle]){
    return binarySearch(array, start + 1, middle - 1, key);
  }

  return binarySearch(array, middle + 1, end - 1 , key);
}