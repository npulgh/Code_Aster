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
#include "asterf_types.h"
    subroutine msesei(fid, it, mname, mgtype, mdim,&
                      smname, setype, snnode, sncell, sgtype,&
                      ncatt, ap, nvatt, cret)
        med_int :: fid
        med_int :: it
        character(len=*) :: mname
        med_int :: mgtype
        med_int :: mdim
        character(len=*) :: smname
        med_int :: setype
        med_int :: snnode
        med_int :: sncell
        med_int :: sgtype
        med_int :: ncatt
        med_int :: ap
        med_int :: nvatt
        med_int :: cret
    end subroutine msesei
end interface
