subroutine cgleff(typfis, nomfis, fonoeu, chfond, basfon,&
                  taillr, conf, lnoff)
    implicit none
#include "jeveux.h"
#include "asterfort/assert.h"
#include "asterfort/dismoi.h"
#include "asterfort/jedema.h"
#include "asterfort/jedupo.h"
#include "asterfort/jeexin.h"
#include "asterfort/jelira.h"
#include "asterfort/jemarq.h"
#include "asterfort/xrecff.h"
!
    character(len=8) :: typfis, nomfis
!
! ======================================================================
! COPYRIGHT (C) 1991 - 2015  EDF R&D                  WWW.CODE-ASTER.ORG
! THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
! IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
! THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
! (AT YOUR OPTION) ANY LATER VERSION.
!
! THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
! WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
! MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
! GENERAL PUBLIC LICENSE FOR MORE DETAILS.
!
! YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
! ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
!   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
! person_in_charge: samuel.geniaut at edf.fr
!
!     SOUS-ROUTINE DE L'OPERATEUR CALC_G
!
!     BUT : LECTURE DE LA DESCRIPTION DU FOND DE FISSURE
!           -> CREATION DES OBJETS FONOEU, CHFOND ET BASFON
!           -> CALCUL DU NOMBRE DE NOEUDS (POINTS) DU FOND : LNOFF
!
!           X-FEM : TRAITEMENT DES MOTS-CLES NUME_FOND ET NB_POINT_FOND
!
!  IN :
!     TYPFIS : TYPE DE LA SD DECRIVANT LE FOND DE FISSURE
!            ('THETA' OU 'FONDIFSS' OU 'FISSURE')
!     NOMFIS : NOM DE LA SD DECRIVANT LE FOND DE FISSURE
!
!  OUT
!     FONOEU : NOMS DES NOEUDS DU FOND DE FISSURE
!     CHFOND : COORDONNES DES POINTS/NOEUDS DU FOND DE FISSURE
!     BASFON : BASE LOCALE AU FOND DE FISSURE
!     TAILLR : TAILLES DES MAILLES CONNECTEES AUX NOEUDS
!     CONF   : CONFIGURATION DE LA FISSURE EN FEM
!     LNOFF  : NOMBRE DE NOEUDS (OU POINTS) DU FOND DE FISSURE
!
! ======================================================================
!
    character(len=8) :: conf
    character(len=24) :: fonoeu, chfond, basfon, taillr
    character(len=24) :: noeuin, fondin, basein
    integer :: ier, lnoff
!
    call jemarq()
!
!     INITIALISATION DES OBJETS PROPRES A CALC_G
!
!     1) FONOEU = NOM DES NOEUDS DU FOND DE FISSURE
    fonoeu = '&&0100.FONDNOEU'
!
!     2) CHFOND = COORDONNEES DES POINTS/NOEUDS DU FOND DE FISSURE
    chfond = '&&0100.FONDFISS'
!
!     3) BASFON = BASE LOCALE AU FOND DE FISSURE
    basfon = '&&0100.BASEFOND'
!
!     4) TAILLR = TAILLES DES MAILLES CONNECTEES AUX NOEUDS
    taillr = '&&0100.TAILLR'
!
    conf = '        '
!
    if (typfis .eq. 'THETA') then
!
!       SI THETA : ON NE PEUT RIEN REMPLIR
!
!       RAJOUTER LA REGLE CAPY EXCLUS THETA ET NUME_FOND
!       RAJOUTER LA REGLE CAPY EXCLUS FOND_FISS ET NUME_FOND
!
    else if (typfis.eq.'FONDFISS') then
!
!       1) VERIF : FONOEU = NOM DES NOEUDS DU FOND DE FISSURE
        noeuin=nomfis//'.FOND.NOEU'
!
!       VERIF D'EXISTENCE (CET OBJET DOIT NORMALEMENT EXISTER CAR
!       LE CAS DES FONDS DOUBLES EST INTERDIT)
        call jeexin(noeuin, ier)
        ASSERT(ier.ne.0)
!
!       2) VERIF : CHFOND = COORDONNEES DES POINTS/NOEUDS DU FOND DE FISSURE
        fondin=nomfis//'.FONDFISS'
!
!       VERIF D'EXISTENCE (CET OBJET DOIT NORMALEMENT EXISTER)
        call jeexin(fondin, ier)
        ASSERT(ier.ne.0)
!
!       3) VERIF : BASEFON = BASE LOCALE AU FOND DE FISSURE
        basein=nomfis//'.BASEFOND'
!
!       VERIF D'EXISTENCE (CET OBJET N'EXISTE QUE SI CONFIG_INIT='COLLEE')
        call dismoi('CONFIG_INIT', nomfis, 'FOND_FISS', repk=conf)
        if (conf .eq. 'COLLEE') then
            call jeexin(basein, ier)
            ASSERT(ier.ne.0)
        endif
        
!       4) CREATION DE LA LISTE DES POINTS DU FOND A CALCULER
!       EN PRENANT EN COMPTE LES MOTS-CLES NUME_FOND ET NB_POINT_FOND
        call xrecff(nomfis, typfis, chfond, basfon, fonoeu, lnoff, conf)
!
!       5) TAILLR = TAILLES DES MAILLES CONNECTEES AUX NOEUDS
        taillr = nomfis//'.FOND.TAILLE_R'
! ======================================================================
!       CET OBJET N'EXISTE QUE SI CONFIG_INIT='COLLEE'
        if (conf .eq. 'COLLEE') then
            call jeexin(taillr, ier)
            ASSERT(ier.ne.0)
        endif
!
    else if (typfis.eq.'FISSURE') then
!
!       1) FONOEU N'EXISTE PAS EN X-FEM
!
!       2) VERIF : CHFOND = COORDONNEES DES POINTS/NOEUDS DU FOND DE FISSURE
        fondin=nomfis//'.FONDFISS'
!
!       VERIF D'EXISTENCE (CET OBJET DOIT NORMALEMENT EXISTER)
        call jeexin(fondin, ier)
        ASSERT(ier.ne.0)
!
!       3) VERIF : BASEFON = BASE LOCALE AU FOND DE FISSURE
        basein=nomfis//'.BASEFOND'
!
!       VERIF D'EXISTENCE (CET OBJET DOIT NORMALEMENT EXISTER)
        call jeexin(basein, ier)
        ASSERT(ier.ne.0)
!
!       4) CREATION DE LA LISTE DES POINTS DU FOND A CALCULER
!       EN PRENANT EN COMPTE LES MOTS-CLES NUME_FOND ET NB_POINT_FOND
        call xrecff(nomfis, typfis, chfond, basfon, fonoeu, lnoff, conf)
!
!       5) TAILLR = TAILLES DES MAILLES CONNECTEES AUX NOEUDS
        taillr = nomfis//'.FOND.TAILLE_R'
!
    endif
!
    call jedema()
!
end subroutine
