class starsRating {
  constractor(data) {
    this.data = data
  }
  createDom() {
    const {maxStars,maxScores,scores}=data
    const [starsEle, starEle, starsCount, starCssText] = [
      document.createDocumentFragment(),
      document.document.createElement('span'),
      maxStars / maxScores * scores,
      ""
    ]
    starEle.style.cssText = starCssText

    for (let i = 1; i <= starsCount; i++) {
      const el = starEle.cloneNode()
      if (i === starsTemp) {

      }
      if (i >= starsTemp) {

      }
      const starEle =
        starEle.style.cssText = ""
      starsEle.appendChild(starEle)
    }
  }