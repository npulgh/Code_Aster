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
    subroutine dicorn(irmetg, nbt, neq, iterat, icodma,&
                      ul, dul, utl, sim, varim,&
                      klv, klv2, varip)
        integer :: neq
        integer :: nbt
        integer :: irmetg
        integer :: iterat
        integer :: icodma
        real(kind=8) :: ul(neq)
        real(kind=8) :: dul(neq)
        real(kind=8) :: utl(neq)
        real(kind=8) :: sim(neq)
        real(kind=8) :: varim(7)
        real(kind=8) :: klv(nbt)
        real(kind=8) :: klv2(nbt)
        real(kind=8) :: varip(7)
    end subroutine dicorn
end interface
