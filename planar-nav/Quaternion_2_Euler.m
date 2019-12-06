function euler=Quaternion_2_Euler(u1,u2,u3,u4)

 Rp2n=[(u2^2)+(u1^2)-(u3^2)-(u4^2) ,   2*((u2*u3)+(u4*u1))       , 2*((u2*u4)-(u3*u1))         ;.... 
          2*((u2*u3)-(u4*u1))     , (u3^2)+(u1^2)-(u2^2)-(u4^2) , 2*((u3*u4)+(u2*u1))          ;....
          2*((u2*u4)+(u3*u1))     ,   2*((u3*u4)-(u2*u1))       , (u4^2)+(u1^2)-(u2^2)-(u3^2)  ]';
  
  
  pith=atan2_0_2pi(-Rp2n(3,1),sqrt(1-(Rp2n(3,1))^2));
  roll=atan2_0_2pi(Rp2n(3,2),Rp2n(3,3));
  yaw =atan2_0_2pi(Rp2n(2,1),Rp2n(1,1));
  
 euler=[roll;pith;yaw];
 
 
 
