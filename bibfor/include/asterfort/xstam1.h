!
! COPYRIGHT (C) 1991 - 2015  EDF R&D                WWW.CODE-ASTER.ORG
!
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
! 1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
!
interface
    subroutine xstam1(noma, nbma, nmafis, mafis,&
                      stano, mafon, maen1, maen2, maen3,&
                      nmafon, nmaen1, nmaen2, nmaen3,&
                      typdis, cnslt)
        integer :: nmafis
        integer :: nbma
        character(len=8) :: noma
        integer :: mafis(nmafis)
        integer :: stano(*)
        integer :: mafon(nmafis)
        integer :: maen1(nbma)
        integer :: maen2(nbma)
        integer :: maen3(nbma)
        integer :: nmafon
        integer :: nmaen1
        integer :: nmaen2
        integer :: nmaen3
        character(len=16) :: typdis
        character(len=19) :: cnslt
    end subroutine xstam1
end interface
