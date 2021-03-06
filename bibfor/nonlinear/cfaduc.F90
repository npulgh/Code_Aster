subroutine cfaduc(resoco, nbliac)
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
! person_in_charge: mickael.abbas at edf.fr
!
    implicit      none
#include "jeveux.h"
#include "asterfort/jedema.h"
#include "asterfort/jemarq.h"
#include "asterfort/jeveuo.h"
    integer :: nbliac
    character(len=24) :: resoco
!
! ----------------------------------------------------------------------
!
! ROUTINE CONTACT (METHODES DISCRETES - RESOLUTION)
!
! CALCUL DU SECOND MEMBRE - CAS DU CONTACT
!
! ----------------------------------------------------------------------
!
!
! IN  RESOCO : SD DE TRAITEMENT NUMERIQUE DU CONTACT
! IN  NBLIAC : NOMBRE DE LIAISONS ACTIVES
!
!
!
!
    integer :: iliai, iliac
    real(kind=8) :: jeuini
    character(len=19) :: liac, mu
    integer :: jliac, jmu
    character(len=24) :: jeux
    integer :: jjeux
!
! ----------------------------------------------------------------------
!
    call jemarq()
!
! --- ACCES STRUCTURES DE DONNEES DE CONTACT
!
    liac = resoco(1:14)//'.LIAC'
    jeux = resoco(1:14)//'.JEUX'
    mu = resoco(1:14)//'.MU'
    call jeveuo(liac, 'L', jliac)
    call jeveuo(jeux, 'L', jjeux)
    call jeveuo(mu, 'E', jmu)
!
! --- ON MET {JEU(DEPTOT)} - [A].{DDEPL0} DANS MU
!
    do 10 iliac = 1, nbliac
        iliai = zi(jliac-1+iliac)
        jeuini = zr(jjeux+3*(iliai-1)+1-1)
        zr(jmu+iliac-1) = jeuini
10  end do
!
    call jedema()
end subroutine
