!
! COPYRIGHT (C) 1991 - 2013  EDF R&D                WWW.CODE-ASTER.ORG
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
#include "types/med_types.h"
    subroutine mfdrpw(fid, fname, numdt, numit, dt,&
                      etype, gtype, stm, pname, lname,&
                      swm, cs, n, val, cret)
        med_int :: fid
        character(*) :: fname
        med_int :: numdt
        med_int :: numit
        real(kind=8) :: dt
        med_int :: etype
        med_int :: gtype
        med_int :: stm
        character(*) :: pname
        character(*) :: lname
        med_int :: swm
        med_int :: cs
        med_int :: n
        real(kind=8) :: val(*)
        med_int :: cret
    end subroutine mfdrpw
end interface
