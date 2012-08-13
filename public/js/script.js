$(function() {

    (function($,sr){

        // debouncing function from John Hann
        // http://unscriptable.com/index.php/2009/03/20/debouncing-javascript-methods/
        var debounce = function (func, threshold, execAsap) {
            var timeout;

            return function debounced () {
                var obj = this, args = arguments;
                function delayed () {
                    if (!execAsap)
                        func.apply(obj, args);
                    timeout = null; 
                };

                if (timeout)
                    clearTimeout(timeout);
                else if (execAsap)
                    func.apply(obj, args);

                timeout = setTimeout(delayed, threshold || 100); 
            };
        }
        // smartresize 
        jQuery.fn[sr] = function(fn){  return fn ? this.bind('resize', debounce(fn)) : this.trigger(sr); };

    })(jQuery,'smartresize');


    (function() {
        var $features = $('.feature');
        var $scroller = $('#featureScroller');
        var $wrapper = $('#featuresWrapper');
        var width = function() {
            var amountVisible = 6;
            if (document.documentElement.clientWidth < 320) {
                amountVisible = 2;
            } else if (document.documentElement.clientWidth < 768) {
                amountVisible = 3;
            }
            return Math.floor($wrapper.width() / amountVisible) - padding;
        };
        var padding = parseInt($features.css('padding-left'), 10) * 2;

        //Append arrow
        $left_arrow = $wrapper.before($("<div class='arrow left'></div>")).prev();
        $right_arrow = $wrapper.after($("<div class='arrow right'></div>")).next();

        setWidthMargin= function() {
            // Width
            $features.css('width', width());
            //Margin
            $scroller.css('margin-left', 0 - width() - padding).css('margin-right', 0 - width() - padding);
            $scroller.css('height', $features.height());
            $left_arrow.css('left', $wrapper.position().left - $left_arrow.width());
            $right_arrow.css('top', $wrapper.position().top).css('left', $wrapper.position().left + $wrapper.width());
        };

        setWidthMargin();
        
        $(window).smartresize(function() {
            setWidthMargin();
        });


        //Click arrow
        duration = 500; // Duration also needs to be changed in the CSS under .move
        $right_arrow.click(function() {
            if ($features.is(':animated')) {
                return false;
            }

            if (Modernizr.csstransitions) {
                $features.addClass('move').css('left', 0 - width() - padding);
                setTimeout(function() {
                    $scroller.children().eq(0).detach().appendTo($scroller);
                    $features.removeClass('move').css({'position' : '', 'left' : ''});
                }, duration);
            } else {
                $features.css('position', 'relative').animate({'left': 0 - width() - padding}, duration);
                setTimeout(function() {
                    $scroller.children().eq(0).detach().appendTo($scroller);
                    $features.css({'position' : 'static', 'left' : ''});
                }, duration);
            }

        });

        $left_arrow.click(function() {
            if ($features.is(':animated')) {
                return false;
            }
            if (Modernizr.csstransitions) {
                $features.addClass('move').css('left', width() + padding);
                setTimeout(function() {
                    $scroller.children().last().detach().prependTo($scroller);
                    $features.removeClass('move').css({'position' : '', 'left' : ''});
                }, duration);
            } else {
                $features.css('position', 'relative').animate({'left': width() + padding},duration);
                setTimeout(function() {
                    $scroller.children().last().detach().prependTo($scroller);
                    $features.css({'position' : 'static', 'left' : ''});
                }, duration);
            }
        });

    })();

});





