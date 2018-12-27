//根据视口大小设置基准字体大小
document.querySelector('html').style.fontSize = getFontSize();

//更改视口大小时动态调整基准字体大小
window.onresize = function () {
   //eslint-disable-next-line
  var viewportWidth=document.documentElement.scrollWidth || document.body.scrollWidth;
  document.querySelector('html').style.fontSize = getFontSize(viewportWidth);
};

function getFontSize(viewportWidth) {
  if (!viewportWidth) {
    viewportWidth =
      document.documentElement.scrollWidth ||
      document.documentElement.scrollWidth ||
      window.innerWidth ||
      document.documentElement.getBoundingClientRect().width;
  }

  let fontSize = viewportWidth * 100 / 1920 + 'px';
  //eslint-disable-next-line
  console.log('当前视口宽度' + viewportWidth + ',html基准字体大小' + fontSize);
  return fontSize;
}
