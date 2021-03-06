subroutine lcmmjs(nomfam, nbsys, tbsys)
    implicit none
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
! person_in_charge: jean-michel.proix at edf.fr
!      ----------------------------------------------------------------
!     MONOCRISTAL : RECUPERATION DES SYSTEMES DE GLISSEMENT UTILISATEUR
!       ----------------------------------------------------------------
    integer :: i, j, nbsys, numfam, decal
    character(len=16) :: nomfam
    real(kind=8) :: tbsys(30, 6), tbsysg
    common/tbsysg/tbsysg(900)
!     ----------------------------------------------------------------
!
! -   NB DE COMPOSANTES / VARIABLES INTERNES -------------------------
!
    read (nomfam(5:5),'(I1)') numfam
    nbsys=nint(tbsysg(2*numfam+1))
    decal=nint(tbsysg(2*numfam+2))
    do 2 i = 1, nbsys
        do 2 j = 1, 6
            tbsys(i,j)=tbsysg(decal-1+6*(i-1)+j)
 2      continue
!
end subroutine
