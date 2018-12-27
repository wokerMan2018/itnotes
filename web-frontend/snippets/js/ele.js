const ele = function(...elesInfo) {
  //获取元素对象
  /*使用方法：
  1. ele('选择器')获取某个选择器对应的节点对象或节点对象列表
  其中：
    a. 选择器返回单个节点对象———id选择器和:nth-child() nth-last-child() :first-child :last-child
    b. 其余返回节点对象列表 如class选择器 元素原则器

  2. ele(
    {
      给获取节点起的名字:'选择器'
    },{
      给获取节点起的名字:'选择器'
    })
   可传入多个对项参数 返回一个包含多个节点内容的对象
   该对象的每个属性（即给获取节点起的名字）的值对应一个节点对象

  例如
   const obj=ele({
     header:'#header'
    },
    {
    footer:'#footer'
    })

   使用obj.header即可得到id为header的元素节点对象

  3. ele({
      给获取节点起的名字:'选择器',index:'第n个选择器'
    })
    同上 新增index属性，用于如果要获取节点对象列表中的第n个节点对象的情况 传入index及对应数字
    例如
     const obj=ele({
      div1:'.div',
      index:0
    })
    使用obj.div1即可获得class为div的节点列表中第0个节点对象
  */

  //1. 如果传入的参数是一个字符串（如'.hide')
  if (elesInfo.length === 1 && typeof elesInfo[0] === 'string') {
    //直接选择器返回对应的节点对象或节点对象列表
    return getNode(elesInfo[0]);
  }

  //2. 传入的参数是一个或多个对象（传入了多个对象）
  //示例ele({msg:'#msg'},{page:'pages',index:1})

  //初始化将要返回的对象
  const nodes = {};

  //参数对象的键名（给 选择器 取得的节点对象（/列表）起的名字） | 参数对象的键值（选择器）

  //遍历参数列表
  for (let item of elesInfo) {
    //获取每个参数（对象）的键名
    const nodeName = Object.keys(item)[0];

    //参数对象是否具有index值
    const index = item.index || null;

    //根据参数对象的键名获取参数对象的键值——选择器
    const selector = item[nodeName];
    //根据参数对象的键值——选择器获取节点对象（或节点对象列表）
    const node = getNode(selector, index);

    //将获取的节点对象（或节点对象列表）存到一个对象上 键名为当前遍历的参数对象的键名 键值为取得的元素节点对象（或节点对象列表）
    nodes[nodeName] = node;
  }

  return nodes;

  function getNode(selector, index = null) {
    //选择器正则
    const reg = /#[\w-]+$|:(first|last)-child$|:nth-(last-)?child\(\d+\)$/;

    //1. 符合正则条件 获取单个节点对象

    if (reg.test(selector)) {
      return document.querySelector(selector);
    }

    //2. 不符合正则条件获取节点对象列表
    const nodeList = document.querySelectorAll(selector);

    // 如果传入了index返回节点对象列表中第index个节点对象
    // 否则返回整个节点对象列表
    return index ? nodeList[index] : nodeList;
  }
};

export default ele;
