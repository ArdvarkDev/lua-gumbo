streq = $(and $(findstring $(1),$(2)),$(findstring $(2),$(1)))
try-run = $(if $(shell $(1) >/dev/null 2>&1 && echo 1),$(2),$(3))
cc-option = $(call try-run,$(CC) $(1) -Werror -c -x c -o /dev/null /dev/null,$(1),$(2))

MAKEFLAGS += -r -Otarget
KERNEL = $(shell uname -s)
DISTRO = $(shell . /etc/os-release && echo "$$NAME $$VERSION_ID")
ARCH = $(shell uname -m)
NPROC = $(or $(shell sh mk/nproc.sh), 1)
CC_VERSION = $(shell $(CC) --version 2>/dev/null | head -n1)
MAKE_S = $(findstring s,$(firstword -$(MAKEFLAGS)))$(filter -s,$(MAKEFLAGS))
XARGS_P = $(call try-run, printf "1\n2" | xargs -P2 -I@ echo '@', -P$(NPROC))
PRINTVAR = printf '\033[1m%15s\033[0m = %s$(2)\n' '$(1)' '$(strip $($(1)))' $(3)
PRINTVARX = $(call PRINTVAR,$(1), \033[32m(%s)\033[0m, '$(origin $(1))')
USERVARS = CC CFLAGS LDFLAGS

AUTOVARS = \
    KERNEL \
    $(if $(call streq,$(KERNEL),Linux), DISTRO) \
    ARCH NPROC MAKE_VERSION CC_VERSION

vars:
	@echo
	@$(foreach VAR, $(AUTOVARS), $(call PRINTVAR,$(VAR));)
	@$(foreach VAR, $(USERVARS), $(call PRINTVARX,$(VAR));)
	@echo
	@$(foreach VAR, $(LUAVARS), $(call PRINTVAR,$(VAR));)
	@echo


.PHONY: vars

ifneq "$(MAKE_S)" ""
  # Make "-s" flag was used (silent build)
  Q = @
  E = @:
else ifeq "$(V)" "1"
  # "V=1" variable was set (verbose build)
  Q =
  E = @:
else
  # Normal build
  Q = @
  E = @printf ' %7s  %s\n'
endif
