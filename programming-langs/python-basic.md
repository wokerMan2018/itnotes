[TOC]
# 环境变量

```shell
export PATH=/path-to-python/bin:$PATH
export PYTHONPATH=/path-to-python/lib/python*/site-packages
```

| 变量名        | 描述                                                         |
| ------------- | ------------------------------------------------------------ |
| PYTHONPATH    | PYTHONPATH是Python搜索路径，默认import的模块都从PYTHONPATH里面寻找。 |
| PYTHONSTARTUP | Python启动后，先寻找PYTHONSTARTUP环境变量，然后执行此变量指定的文件中的代码。 |
| PYTHONCASEOK  | 加入PYTHONCASEOK的环境变量, 就会使python导入模块的时候不区分大小写. |
| PYTHONHOME    | 另一种模块搜索路径。它通常内嵌于的PYTHONSTARTUP或PYTHONPATH目录中，使得两个模块库更容易切换。 |

- Python搜索模块的路径的先后顺序：
  1. 当前程序的主目录
  2. PYTHONPATH目录
  3. 标准连接库目录（一般在`/usr/local/lib/python*`）
  4. 任何的.pth文件的内容（如果存在的话），允许用户把有效果的目录添加到模块搜索路径中去.pth后缀的文本文件中一行一行的地列出目录。

```shell
pip show 模块名  #查看某个模块的安装路径
```

- 指定pip安装目录

  - 在用户家目录建立`.pip.conf`指定模块安装位置

    ```shell
    [install]
    install-option=--prefix=~/.local  #安装到~/.local
    ```

  - `pip install --user paramiko`指定其安装到家目录下。

  - `pip install --install-option="--install-purelib=/python/packages" package_name`

# 基础语法

## 书写格式

- 标识符大小写敏感


- 严格缩进

- 多行语句的行末使用反斜杠`\`  （ []、{}或 () 中的多行语句不需要使用反斜杠除外）

  ```python
  sum = a + \
          b + \
          c
  ```

- 一行书写多条语句使用分号`;`分隔

- 复合语句以冒号` : `结束（如if、while、def和class语句）

```python
print("Hello python")  #输出内容
print("what's your name?")
input()  #接受输入
str="hello"
ver1=3
ver2=3.6
#格式化
print("%s,I use python %d,version is %f" %(str,ver1,ver2))
```

## 编码格式

```python
#coding=utf-8
#或者
#-- coding:UTF-8 --
```
## 注释
使用井号`# `(hash symbol)注释。pyhon无多行注释，但可以使用三引号，达到多行注释的效果（注意缩进）：

```python
"""
	line1
	line2
"""
'''
	line1
	line2
'''
```

## 保留字

即关键字，不能用作标示符名称，可以导入`keyword`模块，然后使用` keyword.kwlist`查看。

# 数据类型

## 标准数据类型

- Number（数字）
  - 整数int
  - 浮点数float
  - 复数complex  在数字后面加上字母`j`
  - 布尔值bool
    - `True`  值为1
    - `False`  值为0
- String（字符串）
- None （空值）
- List（列表）
- Tuple（元组）
- Sets（集合）
- Dictionary（字典）

### 数字number

可以使用十六进制（以0x开头）和八进制（以0开头）来代表整数。

### 字符串string

用单/双/三引号（三引号可以使用单引号或双引号）包裹。

三个引号中使用单双引号、换行、斜杠`\`等**特殊字符均不用转义**。

- unicode字符串前面加上`u`或`U`
- 相邻字符串会连接起来（如'a''b'自动转成'ab'）

#### 操作字符串

- 拼接：加号`+`拼接两个字符串

  ```python
  a='hello-'
  b='-python'
  c=a+b  #c值为'hello--python'
  ```

- 重复：星号`*`重复字符串  ——`str*N`

  str指字符串变量或字符串本身（下同）；N为重复次数，其为一个自然数。

  ```python
  str='yes'
  str*3  #'yesyesyes'
  str*0  #''
  ```

- 索引：方括号`[]`索引字符串中字符

  - 指定位置索引：`str[index]`

    index表示索引位置，第一个位置为0，最后一个位置为-1。

    ```python
    'abcd'[0]    #'a'
    'abcd'[1]    #'b'
    'abcd'[-1]    #'d'
    ```

  - 区间索引（切片）：`str[start:end:step]` 

    start：开始位置，如果省略则值为0；

    end：结束位置，如果省略则值为-1；

    step：步长（在开始和结束区间中截取长度），如果省略则取值为end-start。

    ```python
    'abcd'[0:2]   #'ab'
    'abcd'[0:-1]  #'abc'
    'abcd'[0:]    #'abcd'
    
    'abcd'[:]     #'abcd'
    'abcd'[::]    #'abcd'
    'abcd'[::-1]  #'dcba'
    
    #如果从开始索引为-1，结束索引，得到的是空字符串
    'abcd'[-1::]   #'d'
    'abcd'[-1:0]  #''
    ```

    **索引的结果不包括结束位置上的字符**（*类似数学的前开后闭区间概念*） 。

- `in`和`not in` ：见前文[成员运算符](#成员运算符)

- `r`或`R` ：原始字符串（即不转义） `print(r'\nabc\nabc')`结果是`\nabc\nabc`

- `%`： 格式字符串

  常用的有

  - `%s`格式化字符串
  - `%d`格式化整数
  - `%f`格式化浮点数


#### 转义字符

使用`\`转义。此外python中特别的转义字符：

- `\`  在行尾时表示续行
- `\e`转义
- `\000`空
- `\other`其他的字符以普通格式输出
- `\`后可加上不带`0`或`0x`开头的八进制或十六进制数  
  - `\o12`和`\x0a`表示换行

### 列表list

使用方括号`[]`定义列表，列表内元素以逗号`,`分隔，列表的各个元素的数据类型可以不同。

```python
li=[1,"hello",True]
```

range也可以产生一个列表（前闭后开区间），不过直接返回列表 而是一个range对象 但可以用来遍历。

```python
print(range(1,3))    #range(1,3)  不会打印出来了[1,2]
for x in range(1,3):    #但是可以用于遍历
    print(x)    #1,2
```

#### 操作列表

- 拼接、重复和索引元素：[同字符串的相关操作](操作字符串)。

- 添加元素：`list.append(item)`

- 删除元素

  - `del list[index]`

  - `list.pop(index)` 

    如果index为空，则index将取值为-1。

  - `list.remove(item)`

  ```python
  list1=['x','y','z']
  list1.append('a')  #['x','y','z','a']
  list1.pop(0)  #['y','z','a']
  list1.del(0)  #['z','a']
  list1.remove('z')  #['a']
  ```


- 使用`List[index]`的方式进行索引（同上文字符串的索引方式）。

  ```python
  li[1]  #第1个元素
  li[-1]  #倒数第1个元素
  li[1:3]  #第1到第3个元素
  li[0:]  #第0到最后一个元素（即-1）
  li[:-2]  #倒数第二个到开始的元素（即0）
  li[0]='first'  #修改第0个元素
  li.append('new')  #添加一个元素
  del list[0]  #删除第0个元素
  
  max([1,2,3])    #3  返回最大值，还有min函数返回最小值
  #list(seq)  将元组转换为列表
  ```

- `len()`获取列表长度  （`len([1,2])`长度是2）

- `in`：

  ```python
  3 in [1, 2, 3]    #返回True  在列表中是否有某元素
  #在列表中迭代
  for x in [1, 2, 3]: 
    print(x, end=" ")
  ```

### 元组tuple

使用小括号，且不能修改元素的“列表”。

元组与列表类似，主要区别：

- **元组的元素不能修改**（如果某个元素是一个列表，可以修改该列表的内容）
- **元组使用小括号**
- **元组中只包含一个元素时，需要在元素后面添加逗号**，否则括号会被当作运算符使用。

```python
tup=(1,2,3)
tup1=(100,)
```

### 字典dictionary

大括号`{ }`创建的键值对（key-value pair)集合。

注意：字典中键值对是**乱序**的，且键不可重复。

```python
dict={'boy':7,'girl':5}
```

### 字典操作

- 获取值

  - `dict[key]`

  - `dict.get[key[,default-value]`

    default-value，当要取的键不存在，返回这个给定的值。

  ```shell
  dict={'boy':7,'girl':5}
  dict['boy']  #7
  dict.get('boy')
  dict.get('other','nobody')  #'nobody'
  ```

- 设置值

  `dict[key]=value`修改值，如果该键不存在，将会新建该键值对。

  注意：因为键值对是**乱序**的，不能认为先添加的键值对就在前面。

  ```python
  dict={'apple':7,'orange':5}
  dict[apple]=9  #{'apple': 9,'orange': 5}
  dict[pear]=2  #{'apple': 9,'orange': 5,'pear':2}
  ```

### 集合set

**无序且不重复**的元素集合。

使用大括号`{ }`或者`set()`函数创建集合。

注意：创建一个空集合必须用`set()` 而不是`{ }`，因为`{ }`是用来创建一个空字典。

```python
set={1,2,3}
set=set({1,2,3})
set=set({1})
```
## 数据类型转换 

```python
int(1.1)  #1
float(1)  #1.0
complex(1)    #(1+0j)
complex(1,0j)    #将 x 和 y 转换到一个复数，实数部分为 x，虚数部分为 y。x 和 y 是数字表达式。
str(12)    #'12'
chr(1)  #'1' 将整数转为一个字符
frozenset({1,2})  #转换为不可变集合
bool('hi')    #true
eval('abc')  #计算在字符串中的有效Python表达式,并返回一个对象
```
## 数据类型判断

- `type()`返回数据类型：一个参数--变量或数据内容
- `isinstance()`返回布尔值：两个参数--变量或数据内容，数据类型

```python
a=1
type(a)    #<class 'int'>
type(a)==int    #True
isinstance(a,int)    #True
```
## 推导式

推导式(comprehensions)，又称解析式）是Python的一种独有特性，用以从一个数据序列构建另一个新的数据序列的结构体。 共有三种推导：

- 列表(`list`)推导式

  > 列表推导式（又称列表解析式）提供了一种简明扼要的方法来创建列表。
  > 它的结构是在一个中括号里包含一个表达式，然后是一个`for`语句，然后是0个或多个`for`或者`if`语句。
  >
  > [item for item in list if condition]

  ```python
  nums1 = [i for i in range(10) if i%2==0]
  #或 nums = [i for i in range(10) if i%2 is 0]
  nums2 = [i**2 for i in range(10) if i%2==0]
  print(nums1)  #[0, 2, 4, 6, 8]
  print(nums2)  #[0, 4, 16, 36, 64]
  ```

- 字典(`dict`)推导式

  类似列表推导式，基本格式：

  > { key_expr: value_expr for key,value in collection if condition }

  ```python
  strings={'h':1,'i':2}
  strings = {value: key for key, value in strings.items()}
  print(strings)  #{1: 'h', 2: 'i'}
  ```

- 集合(`set`)推导式



# 变量和运算符

## 变量

- 变量定义和赋值：`变量名=值`

  ```python
  a=b=c=1    #同时为多个变量赋相同的值
  x,y,x=1,2,3   #同时为多个变量赋不同的值
  a+b
  ```

- 常量

  `pi` `e`

## 运算符

### 算数运算符

同大多数编程语言一致，特别的有：

- 混合计算时，整型会转换成为浮点数。

- 数值的除法总是返回一个浮点数，要获取整数使用`//`操作符。

- `**`平方  （也可以使用`math`模块中的`power`函数）

  ```python
  3//2   #1
  2**2    #4
  ```

### 逻辑运算符

- `and` 和
- `or` 或
- `not` 非

### 成员运算符

测试实例中包含了一系列的成员，包括字符串，列表或元组。

- `in`  在指定的序列中找到值返回 True，否则返回 False。
- `not in`  在指定的序列中没有找到值返回 True，否则返回 False。

### 身份运算符

- `is`  判断两个标识符是不是引用自一个对象

- `is not`  is not 是判断两个标识符是不是引用自不同对象

  ```python
  a=1
  b=2
  a is b    #Fasle
  a is not b    #True  （注意is和not之间有空格）
  ```

`is`和`==`以及`is not`和`!=` ：

`is`（或`is not`)用于判断两个变量引用对象是否为同一个对象（或不同对象）， `==`（或`!=`） 用于判断引用变量的值是否相等（或不相等）。

# 输入和输出

- 输入：

  - 键盘输入：`input()`

  - 文件读写：`open(filename,mode)`

    filename是文件名，mode是读写模式：

    - r读
    - w写
    - b二进制
    - +

- 输出：
  - 表达式语句
  - print() 函数
  - 文件对象的 write() 方法（标准输出文件可以用 sys.stdout 引用）

# 流程控制

## if条件

if后的条件语句可以使用括号括起来，也可以不使用括号，条件后面需要以冒号`:`结束。

```python
num = 5     
if num == 3:            # 判断num的值
    print 'boss'        
elif num == 2:
    print 'user'
elif num == 1:
    print 'worker'
elif num < 0:           # 值小于零时输出
    print 'error'
else:
    print 'roadman'     # 条件均不成立时输出
```

## 循环

break 结束循环。

continue 跳过后面的代码，直接开始下一次循环。

### while循环

```python
x = 1
while x <= 3:
    print(x)
    x = x + 1
```

while … else 在循环条件为 false 时执行 else 语句块：

```python
while expression:
    #code...
else:
    #code...
```

### for...in循环

```python
for item in range(1,3):
    print(item)
```

# 函数def

```python
def test(x):
    print(x*x)
#函数调用
test(2)  #4
```

默认参数：在定义函数时对参数赋予默认值。调用函数时，如果未传入该参数的值，将使用其默认值。

```python
def func(x=12)
#其余设略...
func()  #未传入x的值，x将默认取值12
```

# 类class

```python
class Name():
  #...
```

# 模块

## 引用模块

`from 模块名 import 方法名`

```python
from random import randint  #随机整数
	num=randint(1,10)
	print(num)
```

`__future__`模块：引入那些在未来可能会成为标准的模块

```python
import sys
from math import sqrt
from __future__ import division
```



# 正则

引用`re`模块后使用正则表达式。

常用方法：

- 查找

  - findall  返回所有匹配的字符串
  - finditer 返回所有匹配的字符串
  - search 只返回匹配的第一个的字符串
  - match 从字符串起始位置开始匹配
    - 匹配成功返回匹配的第一个的字符串
    - 匹配失败返回None

  以findall为例

  ```python
  re.findall(pattern,string,flags=0)
  ```

  pattern表示正则表达式，string表示原始字符串，flags表示特殊功能。

- 替换

  - sub