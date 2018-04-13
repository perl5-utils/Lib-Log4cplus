#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include <log4cplus/clogger.h>

#include "LLCconfig.h"
#include "const-c.inc"

#define MY_CXT_KEY "Lib::Log4cplus::_guts" XS_VERSION
typedef struct {
    int count;
    SV *initializer;
} my_cxt_t;

START_MY_CXT

MODULE = Lib::Log4cplus::Initializer		PACKAGE = Lib::Log4cplus::Initializer

void
DESTROY(initializer)
    void *initializer;
CODE:
    if(initializer)
	log4cplus_deinitialize(initializer);

MODULE = Lib::Log4cplus		PACKAGE = Lib::Log4cplus

INCLUDE: const-xs.inc

BOOT:
{
    MY_CXT_INIT;
    MY_CXT.count = 0;
    MY_CXT.initializer = newSV(0);
    sv_setref_pv(MY_CXT.initializer, "Lib::Log4cplus::Initializer", log4cplus_initialize());
}

void
CLONE(...)
CODE:
{
    MY_CXT_CLONE;
    MY_CXT.initializer = newSV(0);
    sv_setref_pv(MY_CXT.initializer, "Lib::Log4cplus::Initializer", log4cplus_initialize());
}

void
file_configure (pathname)
	const char *pathname;
PROTOTYPE:
	$
CODE:
{
    int ret_code;
    if(NULL == pathname)
	XSRETURN_UNDEF;

    ret_code = log4cplus_file_configure(pathname);
    ST(0) = sv_2mortal(newSViv(ret_code));
    XSRETURN(1);
}

void
static_configure (configuration)
	const char *configuration;
PROTOTYPE:
	$
CODE:
{
    int ret_code;
    if(NULL == configuration)
	XSRETURN_UNDEF;

    ret_code = log4cplus_str_configure(configuration);
    ST(0) = sv_2mortal(newSViv(ret_code));
    XSRETURN(1);
}

void
basic_configure (out_to_stderr)
	int out_to_stderr;
PROTOTYPE:
CODE:
{
    int ret_code = log4cplus_basic_configure();
    ST(0) = sv_2mortal(newSViv(ret_code));
    XSRETURN(1);
}

void
logger_exists (category)
	const char *category;
PROTOTYPE:
	$
CODE:
{
    int exists = NULL != category ? log4cplus_logger_exists(category) : 1;
    if(exists)
	XSRETURN_YES;
    else
	XSRETURN_NO;
}

void
logger_is_enabled_for (category, log_level)
	const char *category;
	int log_level;
PROTOTYPE:
	$$
CODE:
{
    int is_enabled = log4cplus_logger_is_enabled_for(category, log_level);
    if(is_enabled)
	XSRETURN_YES;
    else
	XSRETURN_NO;
}

void
logger_log (category, log_level, message)
	const char *category;
	int log_level;
	const char *message;
PROTOTYPE:
	$$$
CODE:
{
    int ret_code = NULL != message ? log4cplus_logger_log_str(category, log_level, message) : EINVAL;
    ST(0) = sv_2mortal(newSViv(ret_code));
    XSRETURN(1);
}

void
logger_force_log (category, log_level, message)
	const char *category;
	int log_level;
	const char *message;
PROTOTYPE:
	$$$
CODE:
{
    int ret_code = NULL != message ? log4cplus_logger_force_log_str(category, log_level, message) : EINVAL;
    ST(0) = sv_2mortal(newSViv(ret_code));
    XSRETURN(1);
}
