- 数据类型

  - 原始类型
    - 布尔[Boolean](https://developer.mozilla.org/en-US/docs/Glossary/Boolean)
    - 空[Null](https://developer.mozilla.org/en-US/docs/Glossary/Null)
    - 未定义[Undefined](https://developer.mozilla.org/en-US/docs/Glossary/Undefined)
    - 数字[Number](https://developer.mozilla.org/en-US/docs/Glossary/Number)
    - 字符串[String](https://developer.mozilla.org/en-US/docs/Glossary/String)
    - 符号[Symbol](https://developer.mozilla.org/en-US/docs/Glossary/Symbol)
  - 对象类型[Object](https://developer.mozilla.org/en-US/docs/Glossary/Object)
    - 标准对象和函数
    - 内建对象（如日期对象、数学对象）
    - 有序集——数组和类型数组

- `typeof xx`能够判断的类型

  - 基础数据类型：String Number Boolean Null Undefined symbol
  - 对象类型：function

  注意：`typeof`不能准确判断null和数组，均只能判断其为object

  - 对象
    - Implementation-dependent  宿主对象，由JS环境提供 
    - function  函数对象
    - object  任何其他对象

  - Object.prototype.toString.call()



数据类型判断

- - 
- `xx.constractor`  通过构造函数判断
- `xx instanceof Array`  判断是否为某类型
- `Object.prototype.toString.call([1,2])==='[object Array]'`   最保险的判断