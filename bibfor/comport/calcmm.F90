subroutine calcmm(nbcomm, cpmono, nmat, pgl, nfs,&
                  nsg, toutms, nvi, vind,&
                  irota)
    implicit none
#include "asterfort/lcmmsg.h"
#include "asterfort/utmess.h"
    integer :: nmat, nbcomm(nmat, 3), nvi, irota, nfs, nsg
    real(kind=8) :: pgl(3, 3), toutms(nfs, nsg, 6), vind(*)
    character(len=24) :: cpmono(5*nmat+1)
!
! ======================================================================
! COPYRIGHT (C) 1991 - 2016  EDF R&D                  WWW.CODE-ASTER.ORG
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
!       IN
!         NBCOMM :  NOMBRE DE COEF COEFTIAU PAR FAMILLE
!         CPMONO :  NOMS DES LOIS COEFTIAU PAR FAMILLE
!           NMAT :  NOMBRE MAXI DE COEF MATERIAU
!          PGL   : MATRICE DE PASSAGE GLOBAL LOCAL DU MONOCRISTAL
!         NVI    :  NB VARIABLES INTERNES
!         VIND   :  VARIABLES INTERNES A T
!         IROTA  :  >0 POUR ROTATION DE RESEAU, 0 SINON
!     OUT:
!        TOUTMS  :  TOUS LES TENSEURS MUS=SYM(MS*NS) EN HPP,
!                   TOUS LES VECTEURS MS ET NS EN GDEF
!
!     CETTE ROUTINE CALCULE LES TENSEURS MS POUR GAGNER DU TEMPS
!
!     ----------------------------------------------------------------
    character(len=16) :: nomfam
    real(kind=8) :: ms(6), ng(3), q(3, 3), lg(3), iden(3, 3)
    integer :: nbfsys, i, ifa, nbsys, is, j, ir
    integer :: irr, decirr, nbsyst, decal, gdef
    common/polycr/irr,decirr,nbsyst,decal,gdef
    data iden/1.d0,0.d0,0.d0, 0.d0,1.d0,0.d0, 0.d0,0.d0,1.d0/
!     ----------------------------------------------------------------
!
!         CALCUL DES TENSEURS MS POUR GAGNER DU TEMPS
    nbfsys=nbcomm(nmat,2)
    if (nbfsys .gt. 5) then
        call utmess('F', 'ALGORITH_68')
    endif
    ir=0
!
    if (gdef .eq. 1) then
!  EN VUE D'OPTIMISER, STOCKER LG ET NG
        ir=0
        do ifa = 1, nbfsys
            nomfam=cpmono(5*(ifa-1)+1)(1:16)
            call lcmmsg(nomfam, nbsys, 0, pgl, ms,&
                        ng, lg, ir, q)
            do is = 1, nbsys
                call lcmmsg(nomfam, nbsys, is, pgl, ms,&
                            ng, lg, ir, q)
                do i = 1, 3
                    toutms(ifa,is,i)=lg(i)
                    toutms(ifa,is,i+3)=ng(i)
                end do
            end do
        end do
    else
!
!        ROTATION RESEAU ROTA_RESEAU_CALC - DEBUT
        if (irota .eq. 2) then
            ir=1
            do i = 1, 3
                do j = 1, 3
                    q(i,j)=vind(nvi-19+3*(i-1)+j)+iden(i,j)
                end do
            end do
        endif
        nbcomm(nmat,1)=irota
!        ROTATION RESEAU FIN
!
        do ifa = 1, nbfsys
            nomfam=cpmono(5*(ifa-1)+1)(1:16)
            call lcmmsg(nomfam, nbsys, 0, pgl, ms,&
                        ng, lg, ir, q)
            do is = 1, nbsys
                call lcmmsg(nomfam, nbsys, is, pgl, ms,&
                            ng, lg, ir, q)
                do i = 1, 6
                    toutms(ifa,is,i)=ms(i)
                end do
            end do
        end do
    endif
end subroutine
