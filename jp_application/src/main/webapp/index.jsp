<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Slideshow Gallery</title>

<!-- Bootstrap CSS -->
<link href="https://maxcdn.bootstrapcdn.com/bootstrap/4.1.1/css/bootstrap.min.css" rel="stylesheet">

<!-- Swiper CSS -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/Swiper/4.4.1/css/swiper.min.css">

<!-- Font Awesome -->
<link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.0.13/css/all.css">

<!-- Google Font -->
<link href="https://fonts.googleapis.com/css?family=Oswald:500" rel="stylesheet">

<style>
section {
  width: 100%;
  height: 100vh;
}

.swiper-container {
  width: 100%;
  height: 100%;
}

.slide {
  display: flex;
  justify-content: center;
  align-items: center;
  position: relative;
  text-align: center;
  font-size: 18px;
  background: #fff;
  overflow: hidden;
}

.slide-image {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-position: center;
  background-size: cover;
  background-repeat: no-repeat;
}

.slide-title {
  font-size: 4rem;
  line-height: 1;
  max-width: 80%;
  white-space: normal;
  word-break: break-word;
  color: #FFF;
  z-index: 100;
  font-family: 'Oswald', sans-serif;
  text-transform: uppercase;
  font-weight: normal;
  text-shadow: 2px 2px 4px rgba(0,0,0,0.5);
}

@media (min-width: 45em) {
  .slide-title {
    font-size: 7vw;
    max-width: 70%;
  }
}

.slide-title span {
  white-space: pre;
  display: inline-block;
  opacity: 0;
}

.slideshow {
  position: relative;
}

.slideshow-pagination {
  position: absolute;
  bottom: 5rem;
  left: 0;
  width: 100%;
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  align-items: center;
  transition: .3s opacity;
  z-index: 10;
}

.slideshow-pagination-item {
  display: flex;
  align-items: center;
  margin: 0 10px;
  cursor: pointer;
}

.slideshow-pagination-item .pagination-number {
  opacity: 0.5;
  transition: opacity 0.3s;
}

.slideshow-pagination-item:hover .pagination-number,
.slideshow-pagination-item.active .pagination-number {
  opacity: 1;
}

.slideshow-pagination-item:last-of-type .pagination-separator {
  display: none;
}

.pagination-number {
  font-size: 1.8rem;
  color: #FFF;
  font-family: 'Oswald', sans-serif;
  padding: 0 0.5rem;
  text-shadow: 1px 1px 2px rgba(0,0,0,0.5);
}

.pagination-separator {
  display: block;
  position: relative;
  width: 40px;
  height: 2px;
  background: rgba(255, 255, 255, 0.25);
  transition: all .3s ease;
}

.pagination-separator-loader {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: #FFFFFF;
  transform-origin: 0 0;
  transform: scaleX(0);
}

.slideshow-navigation-button {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  display: flex;
  justify-content: center;
  align-items: center;
  height: 60px;
  width: 60px;
  z-index: 1000;
  transition: all .3s ease;
  color: #FFF;
  background: rgba(0, 0, 0, 0.3);
  border-radius: 50%;
  cursor: pointer;
}

.slideshow-navigation-button:hover {
  background: rgba(0, 0, 0, 0.7);
}

.slideshow-navigation-button.prev {
  left: 20px;
}

.slideshow-navigation-button.next {
  right: 20px;
}

.slideshow-navigation-button span {
  font-size: 24px;
}

/* Make sure navbar doesn't overlap */
/* body {
  padding-top: 56px; /* Adjust based on your navbar height */
} */
</style>
</head>
<body>

<jsp:include page="navbar.jsp"></jsp:include>

<section>
  <div class="swiper-container slideshow">
    <div class="swiper-wrapper">
      <div class="swiper-slide slide">
        <div class="slide-image" style="background-image: url(https://images.unsplash.com/photo-1538083024336-555cf8943ddc?ixlib=rb-1.2.1&auto=format&fit=crop&w=1950&q=80)"></div>
        <span class="slide-title">Exotic places</span>
      </div>

      <div class="swiper-slide slide">
        <div class="slide-image" style="background-image: url(https://images.unsplash.com/photo-1500375592092-40eb2168fd21?ixlib=rb-1.2.1&auto=format&fit=crop&w=2134&q=80)"></div>
        <span class="slide-title">Meet ocean</span>
      </div>

      <div class="swiper-slide slide">
        <div class="slide-image" style="background-image: url(https://images.unsplash.com/photo-1482059470115-0aadd6bf6834?ixlib=rb-1.2.1&auto=format&fit=crop&w=1950&q=80)"></div>
        <span class="slide-title">Around the world</span>
      </div>
    </div>

    <div class="slideshow-pagination"></div>

    <div class="slideshow-navigation">
      <div class="slideshow-navigation-button prev"><span class="fas fa-chevron-left"></span></div>
      <div class="slideshow-navigation-button next"><span class="fas fa-chevron-right"></span></div>
    </div>
  </div>
</section>

<!-- jQuery -->
<script src="https://code.jquery.com/jquery-3.3.1.min.js"></script>

<!-- Bootstrap JS -->
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.1.1/js/bootstrap.min.js"></script>

<!-- Swiper JS -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/Swiper/4.4.1/js/swiper.min.js"></script>

<!-- GSAP -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/2.0.2/TweenMax.min.js"></script>

<!-- Charming.js -->
<script>
!function(e){"undefined"==typeof module?this.charming=e:module.exports=e}(function(e,n){"use strict";n=n||{};var t=n.tagName||"span",o=null!=n.classPrefix?n.classPrefix:"char",r=1,a=function(e){for(var n=e.parentNode,a=e.nodeValue,c=a.length,l=-1;++l<c;){var d=document.createElement(t);o&&(d.className=o+r,r++),d.appendChild(document.createTextNode(a[l])),n.insertBefore(d,e)}n.removeChild(e)};return function c(e){for(var n=[].slice.call(e.childNodes),t=n.length,o=-1;++o<t;)c(n[o]);e.nodeType===Node.TEXT_NODE&&a(e)}(e),e});
</script>

<script>
$(document).ready(function() {
    // The Slideshow class.
    class Slideshow {
        constructor(el) {
            this.DOM = {el: el};
            this.config = {
                slideshow: {
                    delay: 3000,
                    pagination: {
                        duration: 3,
                    }
                }
            };
            this.init();
        }
        
        init() {
            var self = this;
            
            // Charmed title
            this.DOM.slideTitle = this.DOM.el.querySelectorAll('.slide-title');
            this.DOM.slideTitle.forEach((slideTitle) => {
                charming(slideTitle);
            });
            
            // Initialize Swiper
            this.swiper = new Swiper(this.DOM.el, {
                loop: true,
                autoplay: {
                    delay: this.config.slideshow.delay,
                    disableOnInteraction: false,
                },
                speed: 500,
                preloadImages: true,
                updateOnImagesReady: true,
                
                pagination: {
                    el: '.slideshow-pagination',
                    clickable: true,
                    bulletClass: 'slideshow-pagination-item',
                    bulletActiveClass: 'active',
                    renderBullet: function (index, className) {
                        var slideIndex = index,
                            number = (index <= 8) ? '0' + (slideIndex + 1) : (slideIndex + 1);
                        
                        var paginationItem = '<span class="' + className + '">';
                        paginationItem += '<span class="pagination-number">' + number + '</span>';
                        paginationItem += '<span class="pagination-separator"><span class="pagination-separator-loader"></span></span>';
                        paginationItem += '</span>';
                        
                        return paginationItem;
                    },
                },

                navigation: {
                    nextEl: '.slideshow-navigation-button.next',
                    prevEl: '.slideshow-navigation-button.prev',
                },

                on: {
                    init: function() {
                        self.animate('init');
                        self.animatePagination();
                    },
                }
            });
            
            this.initEvents();
        }
        
        initEvents() {
            this.swiper.on('slideChangeTransitionStart', () => {
                const direction = this.swiper.activeIndex > this.swiper.previousIndex ? 'next' : 'prev';
                this.animate(direction);
                this.animatePagination();
            });
            
            this.swiper.on('autoplay', () => {
                this.animatePagination();
            });
        }
        
        animate(direction = 'next') {
            const activeSlide = this.DOM.el.querySelector('.swiper-slide-active');
            if (!activeSlide) return;
            
            const activeSlideImg = activeSlide.querySelector('.slide-image');
            const activeSlideTitle = activeSlide.querySelector('.slide-title');
            const activeSlideTitleLetters = activeSlideTitle.querySelectorAll('span');
            
            // Animate title letters
            activeSlideTitleLetters.forEach((letter, pos) => {
                TweenMax.to(letter, 0.6, {
                    ease: Back.easeOut,
                    delay: pos * 0.05,
                    startAt: {y: '50%', opacity: 0},
                    y: '0%',
                    opacity: 1
                });
            });
            
            // Animate background
            TweenMax.fromTo(activeSlideImg, 1.5, {
                scale: 1.1
            }, {
                scale: 1,
                ease: Expo.easeOut
            });
        }
        
        animatePagination() {
            const activePaginationItem = this.DOM.el.querySelector('.slideshow-pagination-item.active');
            if (!activePaginationItem) return;
            
            const loader = activePaginationItem.querySelector('.pagination-separator-loader');
            if (!loader) return;
            
            // Reset all loaders
            const allLoaders = this.DOM.el.querySelectorAll('.pagination-separator-loader');
            TweenMax.set(allLoaders, {scaleX: 0});
            
            // Animate active loader
            TweenMax.to(loader, this.config.slideshow.pagination.duration, {
                scaleX: 1,
                ease: Linear.easeNone,
                onComplete: () => {
                    // Reset after completion
                    TweenMax.set(loader, {scaleX: 0});
                }
            });
        }
    }
    
    // Initialize slideshow
    const slideshow = new Slideshow(document.querySelector('.slideshow'));
});
</script>

</body>
</html>