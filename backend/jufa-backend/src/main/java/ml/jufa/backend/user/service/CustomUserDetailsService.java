package ml.jufa.backend.user.service;

import lombok.RequiredArgsConstructor;
import ml.jufa.backend.user.repository.UserRepository;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String phone) throws UsernameNotFoundException {
        return userRepository.findByPhone(phone)
            .orElseThrow(() -> new UsernameNotFoundException("User not found with phone: " + phone));
    }
}
