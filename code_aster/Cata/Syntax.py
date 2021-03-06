# coding=utf-8
# ======================================================================
# COPYRIGHT (C) 1991 - 2017  EDF R&D                  WWW.CODE-ASTER.ORG
# THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
# IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
# THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
# (AT YOUR OPTION) ANY LATER VERSION.
#
# THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
# WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
# MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
# GENERAL PUBLIC LICENSE FOR MORE DETAILS.
#
# YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
# ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
#    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
# ======================================================================
# person_in_charge: mathieu.courtois at edf.fr

"""
Module Syntax
-------------

This module defines objects for the commands definition (SIMP, FACT, BLOC...).

It works as a switch between the legacy supervisor and the next generation
of the commands language (already used by AsterStudy).
"""

from . import HAVE_ASTERSTUDY

if not HAVE_ASTERSTUDY:
    from .Legacy.Syntax import *
    from .Legacy.Syntax import _F

else:
    from .Language.Syntax import *


class Translation(object):
    """Class to dynamically assign a translation function.

    The package Cata must stay independent. So the translation function will
    be defined by code_aster or by AsterStudy.
    """

    def __init__(self):
        self._func = lambda arg: arg

    def set_translator(self, translator):
        """Define the translator function.

        Args:
            translator (function): Function returning the translated string.
        """
        self._func = translator

    def __call__(self, arg):
        """Return the translated string"""
        if type(arg) is unicode:
            uarg = arg
        else:
            uarg = arg.decode('utf-8', 'replace')
        return self._func(uarg)

tr = Translation()
