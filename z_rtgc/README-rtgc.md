### init repo
- on 2025-09-26
- Forks https://github.com/dotnet/runtime.git —> dotnet_runtime
- git clone  --depth=1024 https://9e70dd93abc19a3a7cf43b477a84d194ee09035a@github.com/slowcoders/dotnet_runtime.git

### Build 
```sh    
    ./eng/common/native/install-dependencies.sh
    ./build.sh
    ./build.sh --framework net10.0 
```

### test
```sh    
    ./build.sh --test
```
###


### Hints
- INT_STIND_O
- SetObjectReferenceUnchecked
- ErectWriteBarrier → gchelpers.cpp : 기본 WriteBarrier. 실제 사용 시엔 Assembly??<br>
현재는 RememberedSet Card 관리 기능만 있음.
- Thread::ObjectRefAssign → logging: 해당 코드를 찾으면 모든 WriteBarrier 를 찾을 수 있음.
- InlineBulkWriteBarrier → WriteBarrier for Array

