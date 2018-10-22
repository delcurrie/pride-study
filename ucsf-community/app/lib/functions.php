<?php

// http://djomla.blog.com/2011/02/16/php-versions-5-2-and-5-3-get_called_class/
if(!function_exists('get_called_class')) {
    function get_called_class($bt = false, $l = 1) {
        if (!$bt) $bt = debug_backtrace();
        if (!isset($bt[$l])) throw new Exception("Cannot find called class -> stack level too deep.");
        if (!isset($bt[$l]['type'])) {
            throw new Exception ('type not set');
        }
        else switch ($bt[$l]['type']) {
            case '::':
                $lines = file($bt[$l]['file']);
                $i = 0;
                $callerLine = '';
                do {
                    $i++;
                    $callerLine = $lines[$bt[$l]['line']-$i] . $callerLine;
                } while (stripos($callerLine,$bt[$l]['function']) === false);
                preg_match('/([a-zA-Z0-9\_]+)::'.$bt[$l]['function'].'/',
                            $callerLine,
                            $matches);
                if (!isset($matches[1])) {
                    // must be an edge case.
                    throw new Exception ("Could not find caller class: originating method call is obscured.");
                }
                switch ($matches[1]) {
                    case 'self':
                    case 'parent':
                        return get_called_class($bt,$l+1);
                    default:
                        return $matches[1];
                }
                // won't get here.
            case '->': switch ($bt[$l]['function']) {
                    case '__get':
                        // edge case -> get class of calling object
                        if (!is_object($bt[$l]['object'])) throw new Exception ("Edge case fail. __get called on non object.");
                        return get_class($bt[$l]['object']);
                    default: return $bt[$l]['class'];
                }

            default: throw new Exception ("Unknown backtrace method type");
        }
    }
}


function crawlerDetect($setCrawler = null) {
    static $isCrawler;
    if ($setCrawler != null) {
        $isCrawler = (bool)$setCrawler;
    } else {
        if ($isCrawler == null) {
            $crawlers_agents = 'Google|msnbot|Rambler|Yahoo|AbachoBOT|accoona|AcioRobot|ASPSeek|CocoCrawler|Dumbot|FAST-WebCrawler|GeonaBot|Gigabot|Lycos|MSRBOT|Scooter|AltaVista|IDBot|eStyle|Scrubby';
            $isCrawler = !(strpos($crawlers_agents , $_SERVER['HTTP_USER_AGENT']) === false);
        }
    }
    return $isCrawler;
}

function clean_url($url, $allow_slashes = false){
    $url = strtolower(trim($url));
    $url = strip_tags(preg_replace('/&([^;]*);/', '', $url));
    $remove_chars  = array( "([\40])" , "([^a-zA-Z0-9-\.".($allow_slashes?'\/':'')."])", "(-{2,})" );
    $replace_with = array("-", "", "-");
    $url = preg_replace($remove_chars, $replace_with, $url);
    return $url;
}

function setLoginRedirect($include_query_string = true) {
    $app = App::getInstance();
    $_SESSION['LoginRedirect'] = $app->router->getURI() . ($include_query_string && !empty($_SERVER['QUERY_STRING'])?'?'.$_SERVER['QUERY_STRING']:'');
}

function getLoginRedirect($default_redirect = false) {
    $redirect = $_SESSION['LoginRedirect'];
    unset($_SESSION['LoginRedirect']);
    if (empty($redirect)) {
        $redirect = ($default_redirect?$default_redirect:URL_BASE);
    }
    return $redirect;
}

/**
 * Dump something in a pretty manner
 *
 * @param  Mixed $what
 * @return void
 */
function dump($what) {
    echo '<pre>';
    var_dump($what);
    echo '</pre>';
}

/**
 * Dump something and die
 *
 * @param  Mixed $what
 * @return void
 */
function dd($what) {
    dump($what);
    die();
}