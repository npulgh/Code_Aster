!
! COPYRIGHT (C) 1991 - 2016  EDF R&D                WWW.CODE-ASTER.ORG
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
    subroutine rctype(jmat     , nb_para_list, para_list_name, para_list_vale, para_vale,&
                      para_type, keyw_factz  , keywz, materi)
        integer, intent(in) :: jmat
        integer, intent(in) :: nb_para_list
        character(len=*), intent(in) :: para_list_name(*)
        real(kind=8), intent(in) :: para_list_vale(*)
        real(kind=8), intent(out) :: para_vale
        character(len=*), intent(out) :: para_type
        character(len=*), optional, intent(in) :: keyw_factz
        character(len=*), optional, intent(in) :: keywz
        character(len=*), optional, intent(in) :: materi
    end subroutine rctype
end interface
