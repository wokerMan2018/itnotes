//ajax 传参类似jquery的$.ajax()方法
/* 参数示例
info={
  type:'get',  //请求类型
  url:'xxx',  //地址
  data:'xxx',  //发送的数据
  async:'false',  //是否异步
  dataType:'json' //约定的服务器返回数据类型
  success:function(){},  // 服务器已成功处理了请求后执行的方法
  fail:function(){}  //服务器未成功处理了请求
}
*/

const ajax = function(info) {
  //结构传入对象
  let { type, url, data, async, dataType, contentType, success, fail } = info;
  //预设值
  type = type || 'POST';
  async = async || true;
  data = data || null;
  contentType = contentType || 'application/x-www-form-urlencoded';
  dataType = dataType || 'json';
  success =
    success ||
    function() {
      //eslint-disable-next-line no-console
      console.log('没有传输success回调函数');
    };
  fail =
    fail ||
    function(err) {
      //eslint-disable-next-line no-console
      console.log('错误信息：' + err);
    };

  //1. 实例化xhr对象
  const xhr = new XMLHttpRequest();

  //2. 建立请求
  xhr.open(type, url, async);

  if (data) {
    if (data.toString().indexOf('FormData') < 0) {
      xhr.setRequestHeader('Content-type', contentType);
    }
  }

  // xhr.timeout = 3000; //请求超时

  //3. 发送请求
  xhr.send(data);

  //4. 获取回应
  xhr.onreadystatechange = function() {
    if (xhr.readyState === 4) {
      //响应成功200
      if (xhr.status === 200) {
        //取得返回内容
        let res = xhr.responseText;

        if (!res) {
          //eslint-disable-next-line no-console
          console.log(
            '服务端未返回任何内容，可能是服务端程序没启动或者程序出现了故障'
          );
          return;
        }

        //根据约定的返回数据类型进行转换
        res = convertResData(res);
        //转换后的数据调用success回调函数
        success(res);
      }
      //其他响应
      else {
        fail(serverResCode(xhr.status));
      }
    }
  };

  //据约定的返回数据类型（dataType)进行转换
  function convertResData(res) {
    switch (dataType) {
      case 'json':
        return JSON.parse(xhr.responseText);
      default:
        return res;
    }
  }

  //常见服务器返回状态码的处理（除了200)
  function serverResCode(status) {
    let msg = status;
    switch (status) {
      case 0:
        msg += 'XMLHttpRequest出错。（另:在请求完成前，status的值为0。）';
        break;
      case 400:
        msg += '请求参数有误。';
        break;
      case 401:
        msg += '当前请求需要用户验证。';
        break;
      case 403:
        msg += '服务器拒绝执行。';
        break;
      case 404:
        msg += '请求资源未在服务器上发现。';
        break;
      case 414:
        msg +=
          '请求的URI 长度超过了服务器能够解释的长度，因此服务器拒绝对该请求提供服务。';
        break;
      case 431:
        msg += '请求头字段太大。';
        break;
      case 500:
        msg += '服务器错误，服务器不知所措。';
        break;
      case 501:
        msg += '此请求方法不被服务器支持且无法被处理。';
        break;
      case 505:
        msg += '服务器不支持请求中所使用的HTTP协议版本';
        break;
      case 515:
        msg += '客户端需要进行身份验证才能获得网络访问权限。';
        break;
      default:
        break;
    }
    return msg;
  }
};
export default ajax;
