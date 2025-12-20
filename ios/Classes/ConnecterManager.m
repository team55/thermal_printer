//
//  ConnecterManager.m
//  GSDK
//
//

#import "ConnecterManager.h"

@interface ConnecterManager(){
    ConnectMethod currentConnMethod;
}
@end

@implementation ConnecterManager

static ConnecterManager *manager;
static dispatch_once_t once;

+(instancetype)sharedInstance {
    dispatch_once(&once, ^{
        manager = [[ConnecterManager alloc]init];
    });
    return manager;
}

/**
 *  方法说明：扫描外设
 *  @param serviceUUIDs 需要发现外设的UUID，设置为nil则发现周围所有外设
 *  @param options  其它可选操作
 *  @param discover 发现的设备
 */
-(void)scanForPeripheralsWithServices:(nullable NSArray<CBUUID *> *)serviceUUIDs options:(nullable NSDictionary<NSString *, id> *)options discover:(void(^_Nullable)(CBPeripheral *_Nullable peripheral,NSDictionary<NSString *, id> *_Nullable advertisementData,NSNumber *_Nullable RSSI))discover{
    // Ensure BLEConnecter exists - recreate only if it was never created
    // (we don't deallocate it on disconnect to prevent delegate crashes)
    if (_bleConnecter == nil) {
        currentConnMethod = BLUETOOTH;
        [self initConnecter:currentConnMethod];
    }
    [_bleConnecter scanForPeripheralsWithServices:serviceUUIDs options:options discover:discover];
}

/**
 *  方法说明：更新蓝牙状态
 *  @param state 蓝牙状态
 */
-(void)didUpdateState:(void(^)(NSInteger state))state {
    if (_bleConnecter == nil) {
        currentConnMethod = BLUETOOTH;
        [self initConnecter:currentConnMethod];
    }
    [_bleConnecter didUpdateState:state];
}

-(void)initConnecter:(ConnectMethod)connectMethod {
    switch (connectMethod) {
        case BLUETOOTH:
            _bleConnecter = [BLEConnecter new];
            _connecter = _bleConnecter;
            break;
        default:
            break;
    }
}

/**
 *  方法说明：停止扫描
 */
-(void)stopScan {
    if (_bleConnecter != nil) {
        [_bleConnecter stopScan];
    }
}

/**
 *  连接
 */
-(void)connectPeripheral:(CBPeripheral *)peripheral options:(nullable NSDictionary<NSString *,id> *)options timeout:(NSUInteger)timeout connectBlack:(void(^_Nullable)(ConnectState state)) connectState{
    [_bleConnecter connectPeripheral:peripheral options:options timeout:timeout connectBlack:connectState];
}

-(void)connectPeripheral:(CBPeripheral * _Nullable)peripheral options:(nullable NSDictionary<NSString *,id> *)options {
    // Ensure BLEConnecter exists - recreate only if it was never created
    // (we don't deallocate it on disconnect to prevent delegate crashes)
    if (_bleConnecter == nil) {
        currentConnMethod = BLUETOOTH;
        [self initConnecter:currentConnMethod];
    }
    
    // If there's an existing connection, disconnect it first
    if (_bleConnecter.connPeripheral != nil && _bleConnecter.connPeripheral != peripheral) {
        [_bleConnecter closePeripheral:_bleConnecter.connPeripheral];
    }
  
}

-(void)write:(NSData *_Nullable)data progress:(void(^_Nullable)(NSUInteger total,NSUInteger progress))progress receCallBack:(void (^_Nullable)(NSData *_Nullable))callBack {
    [_bleConnecter write:data progress:progress receCallBack:callBack];
}

-(void)write:(NSData *)data receCallBack:(void (^)(NSData *))callBack {
#ifdef DEBUG
    NSLog(@"[ConnecterManager] write:receCallBack:");
#endif
    _bleConnecter.writeProgress = nil;
    [_connecter write:data receCallBack:callBack];
}

-(void)write:(NSData *)data {
#ifdef DEBUG
    NSLog(@"[ConnecterManager] write:");
#endif
   
    // Guard: Check if characteristic exists before writing
    if (_bleConnecter != nil && _bleConnecter.transparentDataWriteChar == nil) {
        NSLog(@"[ConnecterManager] ERROR: Cannot write - transparentDataWriteChar is nil. Characteristics may not be discovered yet.");
        return; // Prevent crash by returning early
    }
    
    _bleConnecter.writeProgress = nil;
    [_connecter write:data];
}

-(void)close {
    // Stop scanning first to prevent new delegate callbacks
    if (_bleConnecter != nil) {
        [_bleConnecter stopScan];
    }
    
    // Properly disconnect the peripheral if connected
    if (_bleConnecter != nil && _bleConnecter.connPeripheral != nil) {
        [_bleConnecter closePeripheral:_bleConnecter.connPeripheral];
    }
    
    // Close the connecter (this should handle delegate cleanup)
    if (_connecter) {
        [_connecter close];
    }


    // IMPORTANT: Do NOT set _bleConnecter = nil here!
    // Core Bluetooth retains a reference to BLEConnecter as a delegate,
    // and can call delegate methods (like centralManagerDidUpdateState:) at any time.
    // If we deallocate BLEConnecter, Core Bluetooth will crash when trying to call these methods.
    // Instead, keep BLEConnecter alive - it can be reused for new connections.
    // The BLEConnecter will handle being disconnected and can accept new connections.
    // switch (currentConnMethod) {
    //     case BLUETOOTH:
    //         _bleConnecter = nil;
    //         break;
    // }
}

@end
