subroutine lcsema(elem_dime  , nb_node_mast   , nb_node_slav, nb_lagr,&
                  norm_smooth, norm           , lagrc,&
                  poidspg    , shape_mast_func, jaco_upda,&
                  vtmp )
!
implicit none
!
#include "jeveux.h"
#include "asterfort/assert.h"
#include "asterfort/jevech.h"
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
!
    integer, intent(in) :: elem_dime
    integer, intent(in) :: nb_node_mast
    integer, intent(in) :: nb_node_slav
    integer, intent(in) :: nb_lagr
    integer, intent(in) :: norm_smooth
    real(kind=8), intent(in) :: norm(3)
    real(kind=8), intent(in) :: shape_mast_func(9)
    real(kind=8), intent(in) :: poidspg
    real(kind=8), intent(in) :: jaco_upda
    real(kind=8), intent(in) :: lagrc
    real(kind=8), intent(inout) :: vtmp(55)
!
! --------------------------------------------------------------------------------------------------
!
! Contact (LAC) - Elementary computations
!
! Compute contact vector (master side)
!
! --------------------------------------------------------------------------------------------------
!
! In  elem_dime        : dimension of elements
! In  nb_lagr          : total number of Lagrangian dof on contact element
! In  nb_node_mast     : number of nodes of for master side from contact element
! In  nb_node_slav     : number of nodes of for slave side from contact element
! In  norm_smooth      : indicator for normals smoothing
! In  norm             : normal at integration point
! In  lagrc            : value of contact pressure (lagrangian)
! In  poidspg          : weight at integration point
! In  shape_slav_func  : shape functions at integration point
! In  jaco_upda        : updated jacobian at integration point
! IO  vtmp             : vector
!
! --------------------------------------------------------------------------------------------------
!
    integer :: i_node_mast, i_dime, jj, jv_norm
    real(kind=8) :: r_nb_lagr
!
! --------------------------------------------------------------------------------------------------
!
    jj        = 0
    r_nb_lagr = real(nb_lagr,kind=8)
!
    if (norm_smooth .eq. 1) then
        call jevech('PSNO', 'L', jv_norm)
        do i_node_mast=1, nb_node_mast                   
            do i_dime=1, elem_dime        
                jj=(i_node_mast-1)*elem_dime+nb_node_slav*elem_dime+nb_lagr+i_dime
                vtmp(jj)= vtmp(jj)+&
                    (zr(jv_norm+nb_node_slav*elem_dime+(i_node_mast-1)*elem_dime+i_dime-1))*&
                     jaco_upda*poidspg*shape_mast_func(i_node_mast)*lagrc
            end do
        end do
    else if (norm_smooth .eq. 0)  then
        do i_node_mast=1, nb_node_mast                   
            do i_dime=1, elem_dime        
                jj=(i_node_mast-1)*elem_dime+nb_node_slav*elem_dime+nb_lagr+i_dime
                vtmp(jj)= vtmp(jj)+&
                    (-norm(i_dime))*&
                    jaco_upda*poidspg*shape_mast_func(i_node_mast)*lagrc
            end do
        end do
    else
        ASSERT(.false.)
    end if
! 
end subroutine
