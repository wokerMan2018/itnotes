backToTop()

function backToTop() {
  const upToTop = document.createElement('div')
  upToTop.textContent = '^回到顶部'
  upToTop.style.cssText = 'display:none;width: 30px;height: 30px;text-shadow:0 0 2px gray;text-align: center;position: fixed;right: 88px;bottom: 288px;border: 1px dashed gray;cursor: pointer;'

  document.body.appendChild(upToTop)

  upToTop.addEventListener('click', function () {
    document.body.scrollTop = document.documentElement.scrollTop = 0;
  })

  window.addEventListener('scroll', function () {
    const topDistance = 150
    if (document.body.scrollTop > topDistance || document.documentElement.scrollTop > topDistance) {
      upToTop.style.display = 'block';
    } else {
      upToTop.style.display = 'none';
    }
  })
}
