# coding=utf-8
# ======================================================================
# COPYRIGHT (C) 1991 - 2016  EDF R&D                  WWW.CODE-ASTER.ORG
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

from SD import *


# sd_partition (utilisee par la sd_modele) :
#--------------------------------------------
class sd_partition(AsBase):
    nomj = SDNom(fin=8)
    PRTI = AsVI(lonmax=1)
    PRTK = AsVK24(lonmax=2)

    # si PRTK(1) in ('MAIL_DISPERSE', 'MAIL_CONTIGU') :
    NUPROC_MAILLE = Facultatif(AsVI(SDNom(nomj='.NUPROC.MAILLE')))

    def check_1(self, checker):
        prti = self.PRTI.get()
        assert prti[0] > 0, prti

        prtk = self.PRTK.get_stripped()
        assert prtk[0] in (
            'SOUS_DOM.OLD', 'GROUP_ELEM', 'SOUS_DOMAINE', 'MAIL_DISPERSE', 'MAIL_CONTIGU'), prtk

        if prtk[0] in ( 'SOUS_DOM.OLD', 'SOUS_DOMAINE' ):
            assert prtk[1] != '', prtk
            sd2 = sd_partit(prtk[1])
            sd2.check(checker)
        else:
            assert prtk[1] == '', prtk

        if prtk[0] in ('MAIL_DISPERSE', 'MAIL_CONTIGU'):
            assert self.NUPROC_MAILLE.exists


# sd_partit :
#----------------------------------------------------
class sd_partit(AsBase):
    nomj = SDNom(fin=19)
    FDIM = AsVI(lonmax=1, )
    FREF = AsVK8(lonmax=1, )
    FETA = AsColl(acces='NO', stockage='DISPERSE',
                  modelong='VARIABLE', type='I', )
